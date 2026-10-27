import 'package:bill_due_reminder/features/bills/domain/app_data.dart';
import 'package:bill_due_reminder/features/bills/domain/bill_ingest.dart';
import 'package:bill_due_reminder/features/bills/domain/bill_service.dart';
import 'package:bill_due_reminder/features/bills/domain/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../fakes.dart';

final statement = sms(
  'VM-HDFCBK',
  '2026-10-16 10:12',
  'HDFC Bank Credit Card ending 4417: Total Amt Due Rs.24,816.50, Min Amt '
      'Due Rs.1,240.00, Due by 04-Nov-26.',
);
final reminder = sms(
  'AD-HDFCBK-S',
  '2026-11-01 09:30',
  'Reminder: Payment of Rs.24,816.50 on your HDFC Bank Credit Card XX4417 is '
      'due on 04/11/2026.',
);
final electricity = sms(
  'VM-BESCOM',
  '2026-10-20 10:00',
  'BESCOM: Bill for Account ID 7812345678 is Rs.1,436.00. Due date '
      '05-11-2026.',
);
final otp = sms(
  'VM-HDFCBK',
  '2026-10-20 10:00',
  '483920 is the OTP for payment of Rs 24,816.50. Do not share it.',
);

void main() {
  late FakeStore store;
  late FakeSms smsSource;
  late FakeReminders reminders;
  var now = DateTime(2026, 10, 27, 12);

  BillService service() => BillService(
    store: store,
    sms: smsSource,
    reminders: reminders,
    clock: () => now,
  );

  setUp(() {
    now = DateTime(2026, 10, 27, 12);
    store = FakeStore();
    smsSource = FakeSms();
    reminders = FakeReminders();
  });

  group('ingestMessages', () {
    test('reads bills, skips the rest, keeps only hashes', () {
      final result = ingestMessages(AppData.empty(), [
        electricity,
        otp,
        statement,
      ]);
      expect(result.data.book.bills.map((b) => b.name), [
        'HDFC Bank',
        'BESCOM',
      ]);
      expect(result.newBills, hasLength(2));
      expect(result.data.processed, hasLength(3));
      expect(
        result.data.processed.any((h) => h.contains('HDFC')),
        isFalse,
        reason: 'hashes, not text',
      );
    });

    test('the same message read twice changes nothing', () {
      final once = ingestMessages(AppData.empty(), [statement]).data;
      final twice = ingestMessages(once, [statement]);
      expect(twice.newBills, isEmpty);
      expect(twice.data.book.bills.single.noticeCount, 1);
    });

    test('a reminder for a known bill merges into it', () {
      final once = ingestMessages(AppData.empty(), [statement]).data;
      final result = ingestMessages(once, [reminder]);
      expect(result.newBills, isEmpty);
      expect(result.data.book.bills.single.noticeCount, 2);
    });

    test('the hash list is capped', () {
      final full = AppData.empty().copyWith(
        processed: [for (var i = 0; i < AppData.maxProcessed; i++) 'h$i'],
      );
      final result = ingestMessages(full, [statement]);
      expect(result.data.processed, hasLength(AppData.maxProcessed));
      expect(result.data.processed.first, 'h1');
    });
  });

  group('BillService', () {
    test('first scan looks back 120 days, then from the last scan', () async {
      smsSource.inbox = [statement, electricity];
      final data = AppData.empty().copyWith(readSms: true, onboarded: true);
      final first = await service().scanInbox(data);
      expect(smsSource.lastSince, now.subtract(BillService.firstScanWindow));
      expect(first.newBills, hasLength(2));
      expect(store.saved!.book.bills, hasLength(2));
      expect(reminders.scheduled, isNotEmpty);

      now = DateTime(2026, 11, 2, 8);
      smsSource.inbox.add(reminder);
      final second = await service().scanInbox(first.data);
      expect(smsSource.lastSince, DateTime(2026, 10, 25, 12).toUtc());
      expect(second.newBills, isEmpty);
      expect(second.data.book.bills, hasLength(2));
    });

    test('no scan without permission or without opt-in', () async {
      smsSource.inbox = [statement];
      final optedOut = await service().scanInbox(AppData.empty());
      expect(optedOut.data.book.bills, isEmpty);

      smsSource.state = SmsAccess.denied;
      final denied = await service().scanInbox(
        AppData.empty().copyWith(readSms: true),
      );
      expect(denied.data.book.bills, isEmpty);
      expect(store.saves, 0);
    });

    test(
      'a new bill SMS in the background is saved, scheduled and announced',
      () async {
        smsSource.arrived = [electricity];
        final result = await service().handleArrived(
          AppData.empty().copyWith(readSms: true),
        );
        expect(result.newBills.single.name, 'BESCOM');
        expect(reminders.announced.single.name, 'BESCOM');
        expect(reminders.scheduled.map((r) => r.fireAt), [
          DateTime(2026, 11, 2, 9),
          DateTime(2026, 11, 4, 9),
          DateTime(2026, 11, 5, 9),
        ]);
        expect(store.saved!.book.bills, hasLength(1));
      },
    );

    test('arrived messages are dropped when SMS reading is off', () async {
      smsSource.arrived = [electricity];
      final result = await service().handleArrived(AppData.empty());
      expect(result.data.book.bills, isEmpty);
      expect(smsSource.arrived, isEmpty);
      expect(reminders.announced, isEmpty);
    });

    test('marking paid cancels its reminders on commit', () async {
      final data = ingestMessages(AppData.empty().copyWith(readSms: true), [
        electricity,
      ]).data;
      final saved = await service().commit(data);
      expect(reminders.scheduled, hasLength(3));
      final id = saved.book.bills.single.id;
      await service().commit(
        saved.copyWith(book: saved.book.markPaid(id, now)),
      );
      expect(reminders.scheduled, isEmpty);
    });

    test('delete all wipes the store and cancels reminders', () async {
      store.saved = ingestMessages(AppData.empty(), [electricity]).data;
      final data = await service().deleteAll();
      expect(store.saved, isNull);
      expect(reminders.cancelled, isTrue);
      expect(data.book.bills, isEmpty);
      expect(data.readSms, isFalse);
    });

    test('AppData JSON round trip', () {
      final data = ingestMessages(
        AppData.empty().copyWith(readSms: true, onboarded: true),
        [statement, electricity],
      ).data.copyWith(lastScanAt: DateTime.utc(2026, 10, 27));
      final back = AppData.fromJson(data.toJson());
      expect(back.book.bills, data.book.bills);
      expect(back.processed, data.processed);
      expect(back.readSms, isTrue);
      expect(back.lastScanAt, data.lastScanAt);
      expect(back.settings, data.settings);
    });
  });

  group('paid by SMS', () {
    final payment = sms(
      'VK-BESCOM',
      '2026-10-28 18:00',
      'BESCOM: Payment of Rs.1,436.00 for Account ID 7812345678 received. '
          'Thank you.',
    );

    test('a payment SMS marks the bill paid and stops its reminders', () async {
      now = DateTime(2026, 10, 28, 18, 5);
      final data = await service().commit(
        ingestMessages(AppData.empty().copyWith(readSms: true), [
          electricity,
        ]).data,
      );
      expect(reminders.scheduled, isNotEmpty);
      smsSource.arrived = [payment];
      final result = await service().handleArrived(data);
      expect(result.paidBills.single.name, 'BESCOM');
      expect(result.data.book.bills.single.paidBy, PaidBy.sms);
      expect(reminders.scheduled, isEmpty);
      expect(reminders.announcedPaid.single.name, 'BESCOM');
      expect(reminders.announced, isEmpty);
    });

    test('bill and payment in one inbox scan end up paid', () async {
      smsSource.inbox = [payment, electricity];
      final result = await service().scanInbox(
        AppData.empty().copyWith(readSms: true),
      );
      expect(result.data.book.bills.single.isPaid, isTrue);
      expect(result.paidBills, hasLength(1));
    });

    test('a payment with no matching bill changes nothing', () {
      final result = ingestMessages(AppData.empty(), [payment]);
      expect(result.data.book.bills, isEmpty);
      expect(result.paidBills, isEmpty);
    });
  });

  test('parsed amounts are whole paise', () {
    final bill = ingestMessages(AppData.empty(), [
      statement,
    ]).data.book.bills.single;
    expect(bill.amountDue, 2481650);
    expect(bill.minimumDue, 124000);
    expect(bill.kind, BillKind.creditCard);
  });
}
