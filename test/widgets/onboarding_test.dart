import 'package:bill_due_reminder/features/bills/domain/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';
import 'harness.dart';

void main() {
  testWidgets('explains SMS access before asking', (tester) async {
    await pumpApp(tester, store: FakeStore());
    await tester.pumpAndSettle();
    expect(find.text('Never miss a due date'), findsOneWidget);
    expect(find.text('What it reads'), findsOneWidget);
    expect(find.text('What it keeps'), findsOneWidget);
    expect(find.textContaining('no internet permission'), findsOneWidget);
  });

  testWidgets('allowing SMS scans the inbox', (tester) async {
    final store = FakeStore();
    final smsSource =
        FakeSms(state: SmsAccess.denied, onRequest: SmsAccess.granted)
          ..inbox = [
            sms(
              'JD-AIRTEL-S',
              '2026-10-20 10:00',
              'Your Airtel postpaid bill for 98XXXXXX21 of Rs.599.00 is due on '
                  '30-Oct-2026.',
            ),
          ];
    await pumpApp(tester, store: store, smsSource: smsSource);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Allow SMS access'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow SMS access'));
    await tester.pumpAndSettle();
    expect(store.saved!.readSms, isTrue);
    expect(find.text('Airtel'), findsOneWidget);
  });

  testWidgets('denying SMS falls back to manual entry', (tester) async {
    final store = FakeStore();
    final smsSource = FakeSms(state: SmsAccess.denied);
    await pumpApp(tester, store: store, smsSource: smsSource);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Allow SMS access'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow SMS access'));
    await tester.pumpAndSettle();
    expect(store.saved!.readSms, isFalse);
    expect(store.saved!.onboarded, isTrue);
    expect(find.textContaining('add bills by hand'), findsOneWidget);
    expect(find.text('Add bill'), findsOneWidget);
  });

  testWidgets('manual mode skips the permission', (tester) async {
    final store = FakeStore();
    final smsSource = FakeSms(
      state: SmsAccess.denied,
      onRequest: SmsAccess.granted,
    );
    await pumpApp(tester, store: store, smsSource: smsSource);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text("I'll add bills myself"), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text("I'll add bills myself"));
    await tester.pumpAndSettle();
    expect(smsSource.state, SmsAccess.denied, reason: 'never asked');
    expect(find.text('No bills yet'), findsOneWidget);
  });
}
