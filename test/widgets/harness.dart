import 'package:bill_due_reminder/app.dart';
import 'package:bill_due_reminder/features/bills/domain/app_data.dart';
import 'package:bill_due_reminder/features/bills/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../fakes.dart';

final DateTime testNow = DateTime(2026, 10, 27, 10);

/// Realistic made-up bills for screens and screenshots.
AppData sampleData() {
  final today = CalendarDate.fromDateTime(testNow);
  TrackedBill sms(
    String id,
    String name,
    BillKind kind,
    int days,
    int amount, {
    String? ref,
    int? minimum,
    int notices = 1,
  }) => TrackedBill(
    id: id,
    kind: kind,
    issuerId: name.split(' ').first.toLowerCase(),
    name: name,
    accountRef: ref,
    amountDue: amount,
    minimumDue: minimum,
    dueDate: today.addDays(days),
    source: BillSource.sms,
    firstSeenAt: DateTime.utc(2026, 10, 10),
    lastSeenAt: DateTime.utc(2026, 10, 20),
    noticeCount: notices,
  );
  return AppData(
    onboarded: true,
    readSms: true,
    book: BillBook([
      sms('a', 'BESCOM', BillKind.electricity, -2, 143600, ref: '5678'),
      sms('b', 'Airtel', BillKind.mobilePostpaid, 0, 59900, ref: '21'),
      sms(
        'c',
        'HDFC Bank',
        BillKind.creditCard,
        3,
        2481650,
        ref: '4417',
        minimum: 124000,
        notices: 2,
      ),
      sms('d', 'Bajaj Finance', BillKind.loanEmi, 4, 349900, ref: '8802'),
      sms('e', 'LIC', BillKind.insurance, 9, 1261800, ref: '5678'),
      sms('f', 'Jio', BillKind.prepaidRecharge, 2, 34900, ref: '56'),
      manualBill(
        'g',
        'Rent',
        today.addDays(-5),
        amount: 1800000,
      ).copyWith(paidAt: DateTime.utc(2026, 10, 21), paidBy: PaidBy.manual),
    ]),
  );
}

/// Pumps the whole app on [location] with fakes.
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeStore store,
  FakeSms? smsSource,
  FakeReminders? reminders,
  String location = '/',
}) async {
  // A typical phone: 411 × 914 dp.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  final router = buildRouter()..go(location);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDataStoreProvider.overrideWithValue(store),
        smsSourceProvider.overrideWithValue(smsSource ?? FakeSms()),
        reminderSchedulerProvider.overrideWithValue(
          reminders ?? FakeReminders(),
        ),
        clockProvider.overrideWithValue(() => testNow),
      ],
      child: DueDayApp(router: router),
    ),
  );
}

extension RouterOf on WidgetTester {
  GoRouter get router => GoRouter.of(element(find.byType(Scaffold).first));
}
