import 'dart:async';

import 'package:bill_due_reminder/features/bills/domain/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';
import 'harness.dart';

class _SlowStore extends FakeStore {
  final Completer<AppData> gate = Completer();

  @override
  Future<AppData> load() => gate.future;
}

void main() {
  testWidgets('loading state', (tester) async {
    final store = _SlowStore();
    await pumpApp(tester, store: store);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    store.gate.complete(sampleData());
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('bills by section with the monthly total', (tester) async {
    await pumpApp(tester, store: FakeStore(sampleData()));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming bills'), findsOneWidget);
    expect(find.text('Due in October'), findsOneWidget);
    // October unpaid: BESCOM 1,436 (overdue) + Airtel 599 + Jio 349 + HDFC
    // 24,816.50 (30 Oct) + Bajaj 3,499 (31 Oct).
    expect(find.text('₹30,699.50'), findsOneWidget);
    expect(find.textContaining('₹18,000 already paid'), findsOneWidget);
    expect(find.text('1 overdue bill: ₹1,436'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Coming up'), findsOneWidget);
    expect(find.text('2 days overdue'), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text('Due in 3 days'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Paid'), 200);
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('empty state with SMS on offers a rescan', (tester) async {
    await pumpApp(
      tester,
      store: FakeStore(
        AppData.empty().copyWith(onboarded: true, readSms: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No bills yet'), findsOneWidget);
    expect(find.text('Scan SMS inbox'), findsOneWidget);
  });

  testWidgets('empty state in manual mode', (tester) async {
    await pumpApp(
      tester,
      store: FakeStore(AppData.empty().copyWith(onboarded: true)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Add your bills'), findsOneWidget);
    expect(find.text('Scan SMS inbox'), findsNothing);
    expect(find.text('Add bill'), findsOneWidget);
  });

  testWidgets('error state retries', (tester) async {
    final store = FakeStore(sampleData())..loadError = StateError('disk');
    await pumpApp(tester, store: store);
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load your bills."), findsOneWidget);
    store.loadError = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming bills'), findsOneWidget);
  });

  testWidgets('mark as paid from the sheet, then undo', (tester) async {
    final store = FakeStore(sampleData());
    final reminders = FakeReminders();
    await pumpApp(tester, store: store, reminders: reminders);
    await tester.pumpAndSettle();
    await tester.tap(find.text('HDFC Bank'));
    await tester.pumpAndSettle();
    expect(find.text('Min. due ₹1,240'), findsOneWidget);
    expect(find.text('Found in 2 SMS'), findsOneWidget);
    await tester.tap(find.text('Mark as paid'));
    await tester.pumpAndSettle();
    expect(store.saved!.book.byId('c')!.isPaid, isTrue);
    expect(reminders.scheduled.any((r) => r.bill.id == 'c'), isFalse);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.saved!.book.byId('c')!.isPaid, isFalse);
  });

  testWidgets('delete from the sheet, then undo', (tester) async {
    final store = FakeStore(sampleData());
    await pumpApp(tester, store: store);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bajaj Finance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(store.saved!.book.byId('d'), isNull);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.saved!.book.byId('d'), isNotNull);
  });

  testWidgets('a bill SMS arriving while open shows up', (tester) async {
    final smsSource = FakeSms();
    final reminders = FakeReminders();
    await pumpApp(
      tester,
      store: FakeStore(
        AppData.empty().copyWith(onboarded: true, readSms: true),
      ),
      smsSource: smsSource,
      reminders: reminders,
    );
    await tester.pumpAndSettle();
    smsSource.deliver(
      sms(
        'VM-BESCOM',
        '2026-10-27 09:00',
        'BESCOM: Bill for Account ID 7812345678 is Rs.1,436.00. Due date '
            '05-11-2026.',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('BESCOM'), findsOneWidget);
    expect(reminders.announced.single.name, 'BESCOM');
  });
}
