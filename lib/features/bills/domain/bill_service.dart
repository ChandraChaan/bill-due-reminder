import 'package:sms_bill_parser/sms_bill_parser.dart';

import 'app_data.dart';
import 'bill_ingest.dart';
import 'reminder_planner.dart';
import 'repositories.dart';

/// The app's use cases: read SMS into bills, save, and keep reminders in
/// step with the bills. Used by the UI and by the background SMS handler.
final class BillService {
  const BillService({
    required this.store,
    required this.sms,
    required this.reminders,
    required this.clock,
  });

  final AppDataStore store;
  final SmsSource sms;
  final ReminderScheduler reminders;
  final DateTime Function() clock;

  /// How far back the first inbox scan looks.
  static const Duration firstScanWindow = Duration(days: 120);

  Future<AppData> load() => store.load();

  /// Reads the inbox since the last scan (or the last [firstScanWindow]) plus
  /// anything that arrived in the background. Returns the saved data and the
  /// bills that are new.
  Future<IngestResult> scanInbox(AppData data) async {
    if (!data.readSms || await sms.access() != SmsAccess.granted) {
      return IngestResult(data, const []);
    }
    final now = clock();
    final since =
        data.lastScanAt?.subtract(const Duration(days: 2)) ??
        now.subtract(firstScanWindow);
    final messages = [
      ...await sms.readInbox(since: since),
      ...await sms.takeArrived(),
    ];
    final result = ingestMessages(data, messages);
    final saved = await commit(result.data.copyWith(lastScanAt: now.toUtc()));
    return IngestResult(saved, result.newBills, result.paidBills);
  }

  /// Reads messages that arrived while the app was closed or in the
  /// background, and announces new bills and bills a payment SMS settled.
  Future<IngestResult> handleArrived(AppData data) async {
    final arrived = await sms.takeArrived();
    if (arrived.isEmpty || !data.readSms) return IngestResult(data, const []);
    final result = ingestMessages(data, arrived);
    final saved = await commit(result.data);
    final upcoming = [
      for (final b in result.newBills)
        if (!b.isPaid && !b.dueDate.isBefore(_today())) b,
    ];
    if (upcoming.isNotEmpty) await reminders.announceNewBills(upcoming);
    if (result.paidBills.isNotEmpty) {
      await reminders.announcePaid(result.paidBills);
    }
    return IngestResult(saved, result.newBills, result.paidBills);
  }

  /// Saves [data] and reschedules every reminder to match it.
  Future<AppData> commit(AppData data) async {
    final pruned = data.copyWith(book: data.book.prune(_today()));
    await store.save(pruned);
    await reminders.replaceAll(
      planReminders(pruned.book.bills, pruned.settings, clock()),
    );
    return pruned;
  }

  /// Removes every bill, setting and scheduled reminder.
  Future<AppData> deleteAll() async {
    await reminders.cancelAll();
    await store.deleteAll();
    return AppData.empty().copyWith(onboarded: true);
  }

  CalendarDate _today() => CalendarDate.fromDateTime(clock());
}
