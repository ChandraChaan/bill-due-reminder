import 'package:sms_bill_parser/sms_bill_parser.dart';

import 'app_data.dart';

/// One notification to show at [fireAt] (local wall-clock time).
final class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.bill,
    required this.daysBefore,
    required this.fireAt,
  });

  /// Notification id, stable for the same bill and day.
  final int id;
  final TrackedBill bill;
  final int daysBefore;
  final DateTime fireAt;

  @override
  String toString() => 'PlannedReminder(${bill.name}, -$daysBefore d, $fireAt)';
}

/// Android allows 500 pending alarms per app; stay well below.
const int maxScheduledReminders = 300;

/// Reminders for every unpaid bill: [ReminderSettings.daysBefore] days before
/// the due date at the chosen time, skipping times already past. Soonest
/// first, at most [maxScheduledReminders].
List<PlannedReminder> planReminders(
  Iterable<TrackedBill> bills,
  ReminderSettings settings,
  DateTime now,
) {
  final planned = <PlannedReminder>[];
  for (final bill in bills) {
    if (bill.isPaid) continue;
    for (final days in settings.daysBefore) {
      final fireAt = bill.dueDate
          .addDays(-days)
          .toLocalDateTime(hour: settings.hour, minute: settings.minute);
      if (!fireAt.isAfter(now)) continue;
      planned.add(
        PlannedReminder(
          id: reminderId(bill.id, days),
          bill: bill,
          daysBefore: days,
          fireAt: fireAt,
        ),
      );
    }
  }
  planned.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return planned.length > maxScheduledReminders
      ? planned.sublist(0, maxScheduledReminders)
      : planned;
}

/// A positive 31-bit notification id for [billId] and [daysBefore].
int reminderId(String billId, int daysBefore) =>
    int.parse(fnv1a64Hex('$billId|$daysBefore').substring(0, 7), radix: 16) +
    1000;
