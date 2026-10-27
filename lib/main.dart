import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'features/bills/data/json_app_data_store.dart';
import 'features/bills/data/local_reminder_scheduler.dart';
import 'features/bills/data/platform_sms_source.dart';
import 'features/bills/domain/bill_service.dart';
import 'features/bills/presentation/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initTimeZone();
  final notifications = await LocalReminderScheduler.initialize();
  runApp(
    ProviderScope(
      overrides: [
        appDataStoreProvider.overrideWithValue(
          JsonAppDataStore(getApplicationSupportDirectory),
        ),
        smsSourceProvider.overrideWithValue(PlatformSmsSource()),
        reminderSchedulerProvider.overrideWithValue(
          LocalReminderScheduler(notifications),
        ),
      ],
      child: const DueDayApp(),
    ),
  );
}

/// Started by `BackgroundSync.kt` in a headless engine when a bill SMS
/// arrives and the app isn't open: reads it, saves the bill, schedules its
/// reminders and tells the Kotlin side it's done.
@pragma('vm:entry-point')
Future<void> smsBackgroundMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  const done = MethodChannel('dev.chandra.bill_due_reminder/background');
  try {
    await _initTimeZone();
    final service = BillService(
      store: JsonAppDataStore(getApplicationSupportDirectory),
      sms: PlatformSmsSource(),
      reminders: LocalReminderScheduler(
        await LocalReminderScheduler.initialize(),
      ),
      clock: DateTime.now,
    );
    await service.handleArrived(await service.load());
  } finally {
    await done.invokeMethod<void>('done');
  }
}

Future<void> _initTimeZone() async {
  tz_data.initializeTimeZones();
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  } on Object catch (error, stack) {
    // Unknown zone name: fall back to India, where this app's bills are.
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }
}
