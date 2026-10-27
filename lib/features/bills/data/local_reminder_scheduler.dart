import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/reminder_planner.dart';
import '../domain/repositories.dart';

/// Schedules reminders with `flutter_local_notifications`, which keeps them
/// in AlarmManager and restores them after a reboot.
final class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler(this._plugin, {this.clock = DateTime.now});

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() clock;

  static const String _dueChannel = 'due_reminders';
  static const String _newChannel = 'new_bills';

  /// Id ranges for "new bill" and "paid" notifications, apart from
  /// reminder ids (which start at 1000).
  static const int _newBillId = 1;
  static const int _paidId = 500;

  AppLocalizations get _l10n => lookupAppLocalizations(const Locale('en'));

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  static Future<FlutterLocalNotificationsPlugin> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
    );
    return plugin;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await _plugin.cancelAllPendingNotifications();
    final l10n = _l10n;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _dueChannel,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
    );
    final today = CalendarDate.fromDateTime(clock());
    for (final reminder in reminders) {
      final bill = reminder.bill;
      final kind = kindLabel(l10n, bill.kind);
      final date = formatDay(bill.dueDate, today);
      await _plugin.zonedSchedule(
        id: reminder.id,
        scheduledDate: tz.TZDateTime(
          tz.local,
          reminder.fireAt.year,
          reminder.fireAt.month,
          reminder.fireAt.day,
          reminder.fireAt.hour,
          reminder.fireAt.minute,
        ),
        notificationDetails: details,
        // Inexact is fine for a morning reminder and needs no exact-alarm
        // permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: l10n.notifDueTitle(
          bill.name,
          bill.amountDue == null ? kind : formatRupees(bill.amountDue!),
        ),
        body: switch (reminder.daysBefore) {
          0 => l10n.notifDueToday(kind),
          1 => l10n.notifDueTomorrow(kind, date),
          final days => l10n.notifDueInDays(kind, days, date),
        },
        payload: bill.id,
      );
    }
  }

  @override
  Future<void> announceNewBills(List<TrackedBill> bills) async {
    final l10n = _l10n;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _newChannel,
        l10n.notifNewChannelName,
        channelDescription: l10n.notifNewChannelDescription,
      ),
    );
    final today = CalendarDate.fromDateTime(clock());
    for (final (i, bill) in bills.indexed) {
      await _plugin.show(
        id: _newBillId + i,
        title: l10n.notifNewBillTitle(bill.name),
        body: l10n.notifNewBillBody(
          kindLabel(l10n, bill.kind),
          bill.amountDue == null ? '' : formatRupees(bill.amountDue!),
          formatDay(bill.dueDate, today),
        ),
        notificationDetails: details,
        payload: bill.id,
      );
    }
  }

  @override
  Future<void> announcePaid(List<TrackedBill> bills) async {
    final l10n = _l10n;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _newChannel,
        l10n.notifNewChannelName,
        channelDescription: l10n.notifNewChannelDescription,
      ),
    );
    for (final (i, bill) in bills.indexed) {
      await _plugin.show(
        id: _paidId + i,
        title: l10n.notifPaidTitle(bill.name),
        body: l10n.notifPaidBody(kindLabel(l10n, bill.kind)),
        notificationDetails: details,
        payload: bill.id,
      );
    }
  }

  @override
  Future<bool> notificationsAllowed() async =>
      await _android?.areNotificationsEnabled() ?? true;

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
