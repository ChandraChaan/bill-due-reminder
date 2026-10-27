// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DueDay';

  @override
  String get homeTitle => 'Upcoming bills';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get addBillTooltip => 'Add a bill';

  @override
  String get addBill => 'Add bill';

  @override
  String monthSummaryTitle(String month) {
    return 'Due in $month';
  }

  @override
  String monthSummaryPaid(String amount) {
    return '$amount already paid';
  }

  @override
  String monthSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills left',
      one: '1 bill left',
      zero: 'No bills left',
    );
    return '$_temp0';
  }

  @override
  String overdueSummary(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue bills',
      one: '1 overdue bill',
    );
    return '$_temp0: $amount';
  }

  @override
  String get sectionOverdue => 'Overdue';

  @override
  String get sectionUpcoming => 'Coming up';

  @override
  String get sectionLater => 'Later';

  @override
  String get sectionPaid => 'Paid';

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String dueInDays(int days) {
    return 'Due in $days days';
  }

  @override
  String overdueByDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String paidOn(String date) {
    return 'Paid $date';
  }

  @override
  String get paidFromSms => 'Paid · from SMS';

  @override
  String get amountUnknown => 'Amount not in SMS';

  @override
  String minimumDue(String amount) {
    return 'Min. due $amount';
  }

  @override
  String accountEnding(String ref) {
    return '•• $ref';
  }

  @override
  String get emptyTitle => 'No bills yet';

  @override
  String get emptyBodySms =>
      'New bill SMS from your bank, card, electricity board or telco will show up here with a reminder before the due date.';

  @override
  String get emptyBodyManual =>
      'Add your bills and DueDay will remind you before each due date. Turn on SMS reading in Settings to add them automatically.';

  @override
  String get emptyScan => 'Scan SMS inbox';

  @override
  String get loadError => 'Couldn\'t load your bills.';

  @override
  String get retry => 'Try again';

  @override
  String get kindCreditCard => 'Credit card';

  @override
  String get kindLoanEmi => 'Loan EMI';

  @override
  String get kindElectricity => 'Electricity';

  @override
  String get kindWater => 'Water';

  @override
  String get kindGas => 'Piped gas';

  @override
  String get kindMobilePostpaid => 'Mobile postpaid';

  @override
  String get kindBroadband => 'Broadband';

  @override
  String get kindPrepaidRecharge => 'Prepaid recharge';

  @override
  String get kindInsurance => 'Insurance premium';

  @override
  String get kindOther => 'Other';

  @override
  String get billMarkPaid => 'Mark as paid';

  @override
  String get billMarkUnpaid => 'Mark as unpaid';

  @override
  String get billEdit => 'Edit';

  @override
  String get billDelete => 'Delete';

  @override
  String get billDeleted => 'Bill deleted';

  @override
  String get billMarkedPaid => 'Marked as paid';

  @override
  String get undo => 'Undo';

  @override
  String billSourceSms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS',
      one: '1 SMS',
    );
    return 'Found in $_temp0';
  }

  @override
  String get billSourceManual => 'Added by you';

  @override
  String get billRepeats => 'Repeats monthly';

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get formTitleAdd => 'Add a bill';

  @override
  String get formTitleEdit => 'Edit bill';

  @override
  String get formName => 'Name';

  @override
  String get formNameHint => 'e.g. Rent, HDFC card, Society maintenance';

  @override
  String get formNameRequired => 'Enter a name';

  @override
  String get formKind => 'Type';

  @override
  String get formAmount => 'Amount (₹)';

  @override
  String get formAmountInvalid => 'Enter an amount like 1,250 or 1250.50';

  @override
  String get formDueDate => 'Due date';

  @override
  String get formRepeat => 'Repeat every month';

  @override
  String get formRepeatHelp =>
      'When you mark it paid, next month\'s bill is added.';

  @override
  String get formSave => 'Save';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSmsSection => 'Reading bill SMS';

  @override
  String get settingsSmsOn => 'On: bank and biller SMS are read on this phone';

  @override
  String get settingsSmsOff => 'Off: you add bills yourself';

  @override
  String get settingsSmsDeniedForever =>
      'SMS permission is blocked. Allow it in Android settings.';

  @override
  String get settingsSmsTurnOn => 'Allow SMS access';

  @override
  String get settingsSmsTurnOff => 'Stop reading SMS';

  @override
  String get settingsOpenAndroid => 'Open Android settings';

  @override
  String get settingsScanNow => 'Scan inbox again';

  @override
  String settingsScanResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new bills found',
      one: '1 new bill found',
      zero: 'No new bills found',
    );
    return '$_temp0';
  }

  @override
  String get settingsRemindersSection => 'Reminders';

  @override
  String get settingsRemindBefore => 'Remind me';

  @override
  String settingsDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before',
      one: '1 day before',
      zero: 'On the due day',
    );
    return '$_temp0';
  }

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsNotificationsOff =>
      'Notifications are off for DueDay, so reminders can\'t be shown.';

  @override
  String get settingsNotificationsAllow => 'Allow notifications';

  @override
  String get settingsPrivacySection => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'DueDay has no internet permission. It reads only SMS from bank and biller sender IDs (like VM‑HDFCBK), keeps only the bill it found (company, last 4 digits, amount, due date) and never stores the message text.';

  @override
  String get settingsDeleteAll => 'Delete all data';

  @override
  String get settingsDeleteAllConfirmTitle => 'Delete everything?';

  @override
  String get settingsDeleteAllConfirmBody =>
      'All bills, paid history and settings are removed from this phone and reminders are cancelled. Your SMS are not touched.';

  @override
  String get settingsDeleteAllConfirm => 'Delete';

  @override
  String get settingsDeleted => 'All data deleted';

  @override
  String get cancel => 'Cancel';

  @override
  String settingsAbout(String version) {
    return 'DueDay $version · open source (MIT)';
  }

  @override
  String get onboardingTitle => 'Never miss a due date';

  @override
  String get onboardingBody =>
      'DueDay finds bills in the SMS your bank, card, electricity board, telco and insurer already send you, and reminds you before they\'re due.';

  @override
  String get onboardingReadsTitle => 'What it reads';

  @override
  String get onboardingReads =>
      'Only SMS from business sender IDs such as VM‑HDFCBK or JD‑AIRTEL‑S. Messages from people and phone numbers are skipped without being read.';

  @override
  String get onboardingKeepsTitle => 'What it keeps';

  @override
  String get onboardingKeeps =>
      'Only the bill: company, last 4 digits, amount and due date. Never the message text, OTPs or contacts.';

  @override
  String get onboardingNetTitle => 'Where it goes';

  @override
  String get onboardingNet =>
      'Nowhere. The app has no internet permission, no account, no ads and no analytics.';

  @override
  String get onboardingAllow => 'Allow SMS access';

  @override
  String get onboardingManual => 'I\'ll add bills myself';

  @override
  String get onboardingDeniedNote =>
      'No problem: you can add bills by hand and turn on SMS reading later in Settings.';

  @override
  String get notifChannelName => 'Bill reminders';

  @override
  String get notifChannelDescription => 'Reminders before a bill is due';

  @override
  String get notifNewChannelName => 'New and paid bills';

  @override
  String get notifNewChannelDescription =>
      'When a bill SMS or a payment confirmation arrives';

  @override
  String notifDueTitle(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String notifDueToday(String kind) {
    return '$kind is due today';
  }

  @override
  String notifDueTomorrow(String kind, String date) {
    return '$kind is due tomorrow ($date)';
  }

  @override
  String notifDueInDays(String kind, int days, String date) {
    return '$kind is due in $days days ($date)';
  }

  @override
  String notifNewBillTitle(String name) {
    return 'New bill: $name';
  }

  @override
  String notifNewBillBody(String kind, String amount, String date) {
    return '$kind $amount, due $date. You\'ll be reminded before then.';
  }

  @override
  String notifPaidTitle(String name) {
    return 'Paid: $name';
  }

  @override
  String notifPaidBody(String kind) {
    return '$kind marked as paid from the payment SMS. Its reminders are off.';
  }

  @override
  String get billPaidFromSmsHelp =>
      'Marked paid from the payment confirmation SMS. Tap \"Mark as unpaid\" if that was a different bill.';
}
