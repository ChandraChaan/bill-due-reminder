import 'package:sms_bill_parser/sms_bill_parser.dart';

/// When reminders fire.
final class ReminderSettings {
  const ReminderSettings({
    this.daysBefore = const {3, 1, 0},
    this.hour = 9,
    this.minute = 0,
  });

  factory ReminderSettings.fromJson(Map<String, Object?> json) =>
      ReminderSettings(
        daysBefore: {
          for (final d in (json['daysBefore']! as List<Object?>)) d! as int,
        },
        hour: json['hour']! as int,
        minute: json['minute']! as int,
      );

  /// Days before the due date to remind; 0 means on the due day.
  final Set<int> daysBefore;

  /// Local time of day for every reminder.
  final int hour;
  final int minute;

  /// The choices offered in Settings.
  static const List<int> choices = [7, 5, 3, 2, 1, 0];

  ReminderSettings copyWith({Set<int>? daysBefore, int? hour, int? minute}) =>
      ReminderSettings(
        daysBefore: daysBefore ?? this.daysBefore,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  Map<String, Object?> toJson() => {
    'daysBefore': (daysBefore.toList()..sort()),
    'hour': hour,
    'minute': minute,
  };

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.hour == hour &&
      other.minute == minute &&
      other.daysBefore.length == daysBefore.length &&
      other.daysBefore.containsAll(daysBefore);

  @override
  int get hashCode =>
      Object.hash(hour, minute, Object.hashAllUnordered(daysBefore));
}

/// Everything the app keeps on the phone.
final class AppData {
  const AppData({
    required this.book,
    this.settings = const ReminderSettings(),
    this.readSms = false,
    this.onboarded = false,
    this.processed = const [],
    this.lastScanAt,
  });

  factory AppData.empty() => AppData(book: BillBook());

  factory AppData.fromJson(Map<String, Object?> json) => AppData(
    book: BillBook([
      for (final b in json['bills']! as List<Object?>)
        TrackedBill.fromJson(b! as Map<String, Object?>),
    ]),
    settings: ReminderSettings.fromJson(
      json['settings']! as Map<String, Object?>,
    ),
    readSms: json['readSms'] as bool? ?? false,
    onboarded: json['onboarded'] as bool? ?? false,
    processed: [
      for (final p in json['processed'] as List<Object?>? ?? const [])
        p! as String,
    ],
    lastScanAt: json['lastScanAt'] == null
        ? null
        : DateTime.parse(json['lastScanAt']! as String),
  );

  final BillBook book;
  final ReminderSettings settings;

  /// The user chose to let the app read bill SMS.
  final bool readSms;

  /// The first-run explainer was shown.
  final bool onboarded;

  /// Hashes of messages already read, newest last, so a message is never
  /// counted twice. Hashes only: the text itself is never stored.
  final List<String> processed;

  /// UTC time of the last inbox scan.
  final DateTime? lastScanAt;

  /// How many message hashes to remember.
  static const int maxProcessed = 3000;

  AppData copyWith({
    BillBook? book,
    ReminderSettings? settings,
    bool? readSms,
    bool? onboarded,
    List<String>? processed,
    DateTime? lastScanAt,
  }) => AppData(
    book: book ?? this.book,
    settings: settings ?? this.settings,
    readSms: readSms ?? this.readSms,
    onboarded: onboarded ?? this.onboarded,
    processed: processed ?? this.processed,
    lastScanAt: lastScanAt ?? this.lastScanAt,
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'bills': [for (final b in book.bills) b.toJson()],
    'settings': settings.toJson(),
    'readSms': readSms,
    'onboarded': onboarded,
    'processed': processed,
    'lastScanAt': lastScanAt?.toIso8601String(),
  };
}
