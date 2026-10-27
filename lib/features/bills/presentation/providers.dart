import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../domain/app_data.dart';
import '../domain/bill_service.dart';
import '../domain/repositories.dart';

/// Overridden in `main.dart` with the real implementations, and in tests
/// with fakes.
final appDataStoreProvider = Provider<AppDataStore>(
  (ref) => throw UnimplementedError('appDataStoreProvider'),
);
final smsSourceProvider = Provider<SmsSource>(
  (ref) => throw UnimplementedError('smsSourceProvider'),
);
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError('reminderSchedulerProvider'),
);
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final billServiceProvider = Provider<BillService>(
  (ref) => BillService(
    store: ref.watch(appDataStoreProvider),
    sms: ref.watch(smsSourceProvider),
    reminders: ref.watch(reminderSchedulerProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The bills and settings, plus everything the user can do with them.
final appDataProvider = AsyncNotifierProvider<AppDataController, AppData>(
  AppDataController.new,
);

final class AppDataController extends AsyncNotifier<AppData> {
  StreamSubscription<void>? _arrivals;

  BillService get _service => ref.read(billServiceProvider);

  @override
  Future<AppData> build() async {
    final service = ref.watch(billServiceProvider);
    _arrivals = ref
        .watch(smsSourceProvider)
        .arrivals
        .listen((_) => unawaited(onArrived()));
    ref.onDispose(() => _arrivals?.cancel());
    var data = await service.load();
    // Catch up on anything that came in while the app was closed.
    data = (await service.scanInbox(data)).data;
    return data;
  }

  Future<void> _update(Future<AppData> Function(AppData data) change) async {
    final current = state.value;
    if (current == null) return;
    final next = await change(current);
    if (!ref.mounted) return;
    state = AsyncData(next);
  }

  /// A bill SMS arrived while the app is open.
  Future<void> onArrived() =>
      _update((data) async => (await _service.handleArrived(data)).data);

  /// Rescans the inbox; returns how many new bills were found.
  Future<int> rescan() async {
    var found = 0;
    await _update((data) async {
      final result = await _service.scanInbox(data);
      found = result.newBills.length;
      return result.data;
    });
    return found;
  }

  /// Reloads from disk: the background handler may have changed the file.
  Future<void> reload() async {
    final data = await _service.load();
    if (!ref.mounted) return;
    state = AsyncData(data);
    await onArrived();
  }

  /// Asks for SMS access and, when granted, reads the inbox.
  Future<SmsAccess> enableSms() async {
    final access = await ref.read(smsSourceProvider).requestAccess();
    await _update((data) async {
      final next = data.copyWith(
        readSms: access == SmsAccess.granted,
        onboarded: true,
      );
      if (access != SmsAccess.granted) return _service.commit(next);
      return (await _service.scanInbox(next)).data;
    });
    return access;
  }

  Future<void> disableSms() =>
      _update((data) => _service.commit(data.copyWith(readSms: false)));

  Future<void> finishOnboarding() =>
      _update((data) => _service.commit(data.copyWith(onboarded: true)));

  Future<void> markPaid(String id) => _update(
    (data) => _service.commit(
      data.copyWith(book: data.book.markPaid(id, ref.read(clockProvider)())),
    ),
  );

  Future<void> markUnpaid(String id) => _update(
    (data) => _service.commit(data.copyWith(book: data.book.markUnpaid(id))),
  );

  /// Deletes a bill and returns it, for undo.
  Future<TrackedBill?> delete(String id) async {
    final bill = state.value?.book.byId(id);
    await _update(
      (data) => _service.commit(data.copyWith(book: data.book.remove(id))),
    );
    return bill;
  }

  Future<void> save(TrackedBill bill) => _update(
    (data) => _service.commit(data.copyWith(book: data.book.upsert(bill))),
  );

  Future<void> updateSettings(ReminderSettings settings) =>
      _update((data) => _service.commit(data.copyWith(settings: settings)));

  Future<void> deleteAll() => _update((_) => _service.deleteAll());
}
