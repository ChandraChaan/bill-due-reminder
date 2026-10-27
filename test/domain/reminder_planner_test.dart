import 'package:bill_due_reminder/features/bills/domain/app_data.dart';
import 'package:bill_due_reminder/features/bills/domain/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../fakes.dart';

void main() {
  final now = DateTime(2026, 10, 27, 12);
  final card = manualBill('a', 'Card', const CalendarDate(2026, 11, 4));

  test('defaults: 3 days before, 1 day before and on the due day at 9:00', () {
    final plan = planReminders([card], const ReminderSettings(), now);
    expect(plan.map((r) => r.fireAt), [
      DateTime(2026, 11, 1, 9),
      DateTime(2026, 11, 3, 9),
      DateTime(2026, 11, 4, 9),
    ]);
    expect(plan.map((r) => r.daysBefore), [3, 1, 0]);
  });

  test('custom days and time', () {
    final plan = planReminders(
      [card],
      const ReminderSettings(daysBefore: {7, 2}, hour: 20, minute: 30),
      now,
    );
    expect(plan.map((r) => r.fireAt), [
      DateTime(2026, 10, 28, 20, 30),
      DateTime(2026, 11, 2, 20, 30),
    ]);
  });

  test('skips times already past', () {
    final soon = manualBill('b', 'Soon', const CalendarDate(2026, 10, 28));
    final plan = planReminders([soon], const ReminderSettings(), now);
    // 3 days before (25 Oct) is past; 1 day before is 27 Oct 9:00, also past.
    expect(plan.map((r) => r.fireAt), [DateTime(2026, 10, 28, 9)]);
  });

  test('a reminder later today is still scheduled', () {
    final morning = DateTime(2026, 11, 4, 8, 59);
    final plan = planReminders([card], const ReminderSettings(), morning);
    expect(plan.single.fireAt, DateTime(2026, 11, 4, 9));
  });

  test('paid and overdue bills get no reminders', () {
    final paid = manualBill(
      'c',
      'Paid',
      const CalendarDate(2026, 11, 10),
      paidAt: DateTime.utc(2026, 10, 26),
    );
    final overdue = manualBill('d', 'Late', const CalendarDate(2026, 10, 20));
    expect(
      planReminders([paid, overdue], const ReminderSettings(), now),
      isEmpty,
    );
  });

  test('sorted across bills and capped', () {
    final bills = [
      for (var i = 0; i < 200; i++)
        manualBill(
          'm$i',
          'Bill $i',
          const CalendarDate(2026, 12, 1).addDays(i),
        ),
    ];
    final plan = planReminders(bills.reversed, const ReminderSettings(), now);
    expect(plan, hasLength(maxScheduledReminders));
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i].fireAt.isBefore(plan[i - 1].fireAt), isFalse);
    }
  });

  test('ids are stable, distinct and positive', () {
    final ids = {
      for (final days in [0, 1, 2, 3, 5, 7]) reminderId('sms-abc', days),
    };
    expect(ids, hasLength(6));
    expect(reminderId('sms-abc', 1), reminderId('sms-abc', 1));
    expect(ids.every((id) => id > 0 && id < 0x7fffffff), isTrue);
  });

  test('settings JSON round trip', () {
    const s = ReminderSettings(daysBefore: {5, 0}, hour: 7, minute: 15);
    expect(ReminderSettings.fromJson(s.toJson()), s);
  });
}
