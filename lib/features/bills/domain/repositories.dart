import 'package:sms_bill_parser/sms_bill_parser.dart';

import 'app_data.dart';
import 'reminder_planner.dart';

/// Saves [AppData] on the phone.
abstract interface class AppDataStore {
  Future<AppData> load();
  Future<void> save(AppData data);
  Future<void> deleteAll();
}

enum SmsAccess { granted, denied, blocked }

/// Bill SMS from the phone. Implementations hand over only messages whose
/// sender is a business header (see `isBusinessSender`); personal messages
/// never leave the platform side.
abstract interface class SmsSource {
  Future<SmsAccess> access();
  Future<SmsAccess> requestAccess();

  /// Business messages received after [since], oldest first.
  Future<List<SmsInput>> readInbox({required DateTime since});

  /// Messages that arrived while the app wasn't looking, oldest first.
  /// Each message is handed out once.
  Future<List<SmsInput>> takeArrived();

  /// Fires when a new business SMS arrives while the app is open.
  Stream<void> get arrivals;

  Future<void> openAppSettings();
}

/// Posts reminder notifications.
abstract interface class ReminderScheduler {
  /// Cancels every scheduled reminder and schedules [reminders] instead.
  Future<void> replaceAll(List<PlannedReminder> reminders);

  /// Shows "new bill found" right away.
  Future<void> announceNewBills(List<TrackedBill> bills);

  Future<bool> notificationsAllowed();
  Future<bool> requestPermission();
  Future<void> cancelAll();
}
