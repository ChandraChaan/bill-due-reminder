import 'dart:async';

import 'package:bill_due_reminder/features/bills/domain/app_data.dart';
import 'package:bill_due_reminder/features/bills/domain/reminder_planner.dart';
import 'package:bill_due_reminder/features/bills/domain/repositories.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

class FakeStore implements AppDataStore {
  FakeStore([AppData? data]) : saved = data;

  AppData? saved;
  Object? loadError;
  int saves = 0;

  @override
  Future<AppData> load() async {
    if (loadError != null) throw loadError!;
    return saved ?? AppData.empty();
  }

  @override
  Future<void> save(AppData data) async {
    saved = data;
    saves++;
  }

  @override
  Future<void> deleteAll() async => saved = null;
}

final class FakeSms implements SmsSource {
  FakeSms({this.state = SmsAccess.granted, this.onRequest});

  SmsAccess state;
  SmsAccess? onRequest;
  List<SmsInput> inbox = [];
  List<SmsInput> arrived = [];
  DateTime? lastSince;
  final StreamController<void> _arrivals = StreamController.broadcast();

  void deliver(SmsInput sms) {
    arrived.add(sms);
    _arrivals.add(null);
  }

  @override
  Future<SmsAccess> access() async => state;

  @override
  Future<SmsAccess> requestAccess() async => state = onRequest ?? state;

  @override
  Future<List<SmsInput>> readInbox({required DateTime since}) async {
    lastSince = since;
    return inbox.where((m) => m.receivedAt.isAfter(since)).toList();
  }

  @override
  Future<List<SmsInput>> takeArrived() async {
    final out = arrived;
    arrived = [];
    return out;
  }

  @override
  Stream<void> get arrivals => _arrivals.stream;

  @override
  Future<void> openAppSettings() async {}
}

final class FakeReminders implements ReminderScheduler {
  List<PlannedReminder> scheduled = [];
  List<TrackedBill> announced = [];
  List<TrackedBill> announcedPaid = [];
  bool allowed = true;
  bool cancelled = false;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async =>
      scheduled = reminders;

  @override
  Future<void> announceNewBills(List<TrackedBill> bills) async =>
      announced.addAll(bills);

  @override
  Future<void> announcePaid(List<TrackedBill> bills) async =>
      announcedPaid.addAll(bills);

  @override
  Future<bool> notificationsAllowed() async => allowed;

  @override
  Future<bool> requestPermission() async => allowed;

  @override
  Future<void> cancelAll() async {
    cancelled = true;
    scheduled = [];
  }
}

SmsInput sms(String sender, String received, String body) =>
    SmsInput(sender: sender, body: body, receivedAt: DateTime.parse(received));

TrackedBill manualBill(
  String id,
  String name,
  CalendarDate due, {
  int? amount,
  BillKind kind = BillKind.other,
  DateTime? paidAt,
  String? ref,
  BillSource source = BillSource.manual,
}) => TrackedBill(
  id: id,
  kind: kind,
  issuerId: source == BillSource.manual ? 'manual' : name.toLowerCase(),
  name: name,
  accountRef: ref,
  amountDue: amount,
  dueDate: due,
  source: source,
  firstSeenAt: DateTime.utc(2026, 10, 1),
  lastSeenAt: DateTime.utc(2026, 10, 1),
  paidAt: paidAt,
  paidBy: paidAt == null ? null : PaidBy.manual,
);
