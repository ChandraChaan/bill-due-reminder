import 'package:bill_due_reminder/features/bills/domain/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../fakes.dart';
import 'harness.dart';

void main() {
  testWidgets('add a monthly bill by hand', (tester) async {
    final store = FakeStore(AppData.empty().copyWith(onboarded: true));
    final reminders = FakeReminders();
    await pumpApp(tester, store: store, reminders: reminders);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add bill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a name'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Rent');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (₹)'),
      '18,000',
    );
    await tester.tap(find.text('Repeat every month'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final bill = store.saved!.book.bills.single;
    expect(bill.name, 'Rent');
    expect(bill.amountDue, 1800000);
    expect(bill.dueDate, const CalendarDate(2026, 11, 3));
    expect(bill.repeatMonthly, isTrue);
    expect(reminders.scheduled, hasLength(3));
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('rejects a bad amount', (tester) async {
    await pumpApp(
      tester,
      store: FakeStore(AppData.empty().copyWith(onboarded: true)),
      location: '/add',
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Gym');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (₹)'),
      '12.345',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.textContaining('Enter an amount'), findsOneWidget);
  });

  testWidgets('edit an SMS bill amount', (tester) async {
    final store = FakeStore(sampleData());
    await pumpApp(tester, store: store, location: '/edit/c');
    await tester.pumpAndSettle();
    expect(find.text('Edit bill'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (₹)'),
      '20000',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.saved!.book.byId('c')!.amountDue, 2000000);
  });

  testWidgets('reminder days can be changed', (tester) async {
    final store = FakeStore(sampleData());
    await pumpApp(tester, store: store, location: '/settings');
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 days before'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On the due day'));
    await tester.pumpAndSettle();
    expect(store.saved!.settings.daysBefore, {7, 3, 1});
  });

  testWidgets('delete all asks first, then wipes everything', (tester) async {
    final store = FakeStore(sampleData());
    final reminders = FakeReminders();
    await pumpApp(
      tester,
      store: store,
      reminders: reminders,
      location: '/settings',
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Delete all data'), 200);
    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.saved, isNotNull);

    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(store.saved, isNull);
    expect(reminders.cancelled, isTrue);
    expect(find.text('All data deleted'), findsOneWidget);
  });

  testWidgets('notifications off shows a warning', (tester) async {
    await pumpApp(
      tester,
      store: FakeStore(sampleData()),
      reminders: FakeReminders()..allowed = false,
      location: '/settings',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Notifications are off'), findsOneWidget);
  });
}
