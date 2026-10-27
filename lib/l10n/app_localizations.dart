import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DueDay'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming bills'**
  String get homeTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @addBillTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a bill'**
  String get addBillTooltip;

  /// No description provided for @addBill.
  ///
  /// In en, this message translates to:
  /// **'Add bill'**
  String get addBill;

  /// No description provided for @monthSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Due in {month}'**
  String monthSummaryTitle(String month);

  /// No description provided for @monthSummaryPaid.
  ///
  /// In en, this message translates to:
  /// **'{amount} already paid'**
  String monthSummaryPaid(String amount);

  /// No description provided for @monthSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No bills left} =1{1 bill left} other{{count} bills left}}'**
  String monthSummaryCount(int count);

  /// No description provided for @overdueSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue bill} other{{count} overdue bills}}: {amount}'**
  String overdueSummary(int count, String amount);

  /// No description provided for @sectionOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get sectionOverdue;

  /// No description provided for @sectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get sectionUpcoming;

  /// No description provided for @sectionLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get sectionLater;

  /// No description provided for @sectionPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get sectionPaid;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String dueInDays(int days);

  /// No description provided for @overdueByDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day overdue} other{{days} days overdue}}'**
  String overdueByDays(int days);

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid {date}'**
  String paidOn(String date);

  /// No description provided for @paidFromSms.
  ///
  /// In en, this message translates to:
  /// **'Paid · from SMS'**
  String get paidFromSms;

  /// No description provided for @amountUnknown.
  ///
  /// In en, this message translates to:
  /// **'Amount not in SMS'**
  String get amountUnknown;

  /// No description provided for @minimumDue.
  ///
  /// In en, this message translates to:
  /// **'Min. due {amount}'**
  String minimumDue(String amount);

  /// No description provided for @accountEnding.
  ///
  /// In en, this message translates to:
  /// **'•• {ref}'**
  String accountEnding(String ref);

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bills yet'**
  String get emptyTitle;

  /// No description provided for @emptyBodySms.
  ///
  /// In en, this message translates to:
  /// **'New bill SMS from your bank, card, electricity board or telco will show up here with a reminder before the due date.'**
  String get emptyBodySms;

  /// No description provided for @emptyBodyManual.
  ///
  /// In en, this message translates to:
  /// **'Add your bills and DueDay will remind you before each due date. Turn on SMS reading in Settings to add them automatically.'**
  String get emptyBodyManual;

  /// No description provided for @emptyScan.
  ///
  /// In en, this message translates to:
  /// **'Scan SMS inbox'**
  String get emptyScan;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your bills.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @kindCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get kindCreditCard;

  /// No description provided for @kindLoanEmi.
  ///
  /// In en, this message translates to:
  /// **'Loan EMI'**
  String get kindLoanEmi;

  /// No description provided for @kindElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get kindElectricity;

  /// No description provided for @kindWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get kindWater;

  /// No description provided for @kindGas.
  ///
  /// In en, this message translates to:
  /// **'Piped gas'**
  String get kindGas;

  /// No description provided for @kindMobilePostpaid.
  ///
  /// In en, this message translates to:
  /// **'Mobile postpaid'**
  String get kindMobilePostpaid;

  /// No description provided for @kindBroadband.
  ///
  /// In en, this message translates to:
  /// **'Broadband'**
  String get kindBroadband;

  /// No description provided for @kindPrepaidRecharge.
  ///
  /// In en, this message translates to:
  /// **'Prepaid recharge'**
  String get kindPrepaidRecharge;

  /// No description provided for @kindInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance premium'**
  String get kindInsurance;

  /// No description provided for @kindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get kindOther;

  /// No description provided for @billMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get billMarkPaid;

  /// No description provided for @billMarkUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as unpaid'**
  String get billMarkUnpaid;

  /// No description provided for @billEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get billEdit;

  /// No description provided for @billDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get billDelete;

  /// No description provided for @billDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bill deleted'**
  String get billDeleted;

  /// No description provided for @billMarkedPaid.
  ///
  /// In en, this message translates to:
  /// **'Marked as paid'**
  String get billMarkedPaid;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @billSourceSms.
  ///
  /// In en, this message translates to:
  /// **'Found in {count, plural, =1{1 SMS} other{{count} SMS}}'**
  String billSourceSms(int count);

  /// No description provided for @billSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get billSourceManual;

  /// No description provided for @billRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats monthly'**
  String get billRepeats;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @formTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a bill'**
  String get formTitleAdd;

  /// No description provided for @formTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit bill'**
  String get formTitleEdit;

  /// No description provided for @formName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get formName;

  /// No description provided for @formNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rent, HDFC card, Society maintenance'**
  String get formNameHint;

  /// No description provided for @formNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get formNameRequired;

  /// No description provided for @formKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get formKind;

  /// No description provided for @formAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get formAmount;

  /// No description provided for @formAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 1,250 or 1250.50'**
  String get formAmountInvalid;

  /// No description provided for @formDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get formDueDate;

  /// No description provided for @formRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat every month'**
  String get formRepeat;

  /// No description provided for @formRepeatHelp.
  ///
  /// In en, this message translates to:
  /// **'When you mark it paid, next month\'s bill is added.'**
  String get formRepeatHelp;

  /// No description provided for @formSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get formSave;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSmsSection.
  ///
  /// In en, this message translates to:
  /// **'Reading bill SMS'**
  String get settingsSmsSection;

  /// No description provided for @settingsSmsOn.
  ///
  /// In en, this message translates to:
  /// **'On: bank and biller SMS are read on this phone'**
  String get settingsSmsOn;

  /// No description provided for @settingsSmsOff.
  ///
  /// In en, this message translates to:
  /// **'Off: you add bills yourself'**
  String get settingsSmsOff;

  /// No description provided for @settingsSmsDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'SMS permission is blocked. Allow it in Android settings.'**
  String get settingsSmsDeniedForever;

  /// No description provided for @settingsSmsTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Allow SMS access'**
  String get settingsSmsTurnOn;

  /// No description provided for @settingsSmsTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Stop reading SMS'**
  String get settingsSmsTurnOff;

  /// No description provided for @settingsOpenAndroid.
  ///
  /// In en, this message translates to:
  /// **'Open Android settings'**
  String get settingsOpenAndroid;

  /// No description provided for @settingsScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan inbox again'**
  String get settingsScanNow;

  /// No description provided for @settingsScanResult.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new bills found} =1{1 new bill found} other{{count} new bills found}}'**
  String settingsScanResult(int count);

  /// No description provided for @settingsRemindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsRemindersSection;

  /// No description provided for @settingsRemindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get settingsRemindBefore;

  /// No description provided for @settingsDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{On the due day} =1{1 day before} other{{days} days before}}'**
  String settingsDaysBefore(int days);

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for DueDay, so reminders can\'t be shown.'**
  String get settingsNotificationsOff;

  /// No description provided for @settingsNotificationsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get settingsNotificationsAllow;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacySection;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'DueDay has no internet permission. It reads only SMS from bank and biller sender IDs (like VM‑HDFCBK), keeps only the bill it found (company, last 4 digits, amount, due date) and never stores the message text.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get settingsDeleteAllConfirmTitle;

  /// No description provided for @settingsDeleteAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All bills, paid history and settings are removed from this phone and reminders are cancelled. Your SMS are not touched.'**
  String get settingsDeleteAllConfirmBody;

  /// No description provided for @settingsDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAllConfirm;

  /// No description provided for @settingsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get settingsDeleted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'DueDay {version} · open source (MIT)'**
  String settingsAbout(String version);

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a due date'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'DueDay finds bills in the SMS your bank, card, electricity board, telco and insurer already send you, and reminds you before they\'re due.'**
  String get onboardingBody;

  /// No description provided for @onboardingReadsTitle.
  ///
  /// In en, this message translates to:
  /// **'What it reads'**
  String get onboardingReadsTitle;

  /// No description provided for @onboardingReads.
  ///
  /// In en, this message translates to:
  /// **'Only SMS from business sender IDs such as VM‑HDFCBK or JD‑AIRTEL‑S. Messages from people and phone numbers are skipped without being read.'**
  String get onboardingReads;

  /// No description provided for @onboardingKeepsTitle.
  ///
  /// In en, this message translates to:
  /// **'What it keeps'**
  String get onboardingKeepsTitle;

  /// No description provided for @onboardingKeeps.
  ///
  /// In en, this message translates to:
  /// **'Only the bill: company, last 4 digits, amount and due date. Never the message text, OTPs or contacts.'**
  String get onboardingKeeps;

  /// No description provided for @onboardingNetTitle.
  ///
  /// In en, this message translates to:
  /// **'Where it goes'**
  String get onboardingNetTitle;

  /// No description provided for @onboardingNet.
  ///
  /// In en, this message translates to:
  /// **'Nowhere. The app has no internet permission, no account, no ads and no analytics.'**
  String get onboardingNet;

  /// No description provided for @onboardingAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow SMS access'**
  String get onboardingAllow;

  /// No description provided for @onboardingManual.
  ///
  /// In en, this message translates to:
  /// **'I\'ll add bills myself'**
  String get onboardingManual;

  /// No description provided for @onboardingDeniedNote.
  ///
  /// In en, this message translates to:
  /// **'No problem: you can add bills by hand and turn on SMS reading later in Settings.'**
  String get onboardingDeniedNote;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Bill reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders before a bill is due'**
  String get notifChannelDescription;

  /// No description provided for @notifNewChannelName.
  ///
  /// In en, this message translates to:
  /// **'New and paid bills'**
  String get notifNewChannelName;

  /// No description provided for @notifNewChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'When a bill SMS or a payment confirmation arrives'**
  String get notifNewChannelDescription;

  /// No description provided for @notifDueTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}: {amount}'**
  String notifDueTitle(String name, String amount);

  /// No description provided for @notifDueToday.
  ///
  /// In en, this message translates to:
  /// **'{kind} is due today'**
  String notifDueToday(String kind);

  /// No description provided for @notifDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{kind} is due tomorrow ({date})'**
  String notifDueTomorrow(String kind, String date);

  /// No description provided for @notifDueInDays.
  ///
  /// In en, this message translates to:
  /// **'{kind} is due in {days} days ({date})'**
  String notifDueInDays(String kind, int days, String date);

  /// No description provided for @notifNewBillTitle.
  ///
  /// In en, this message translates to:
  /// **'New bill: {name}'**
  String notifNewBillTitle(String name);

  /// No description provided for @notifNewBillBody.
  ///
  /// In en, this message translates to:
  /// **'{kind} {amount}, due {date}. You\'ll be reminded before then.'**
  String notifNewBillBody(String kind, String amount, String date);

  /// No description provided for @notifPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Paid: {name}'**
  String notifPaidTitle(String name);

  /// No description provided for @notifPaidBody.
  ///
  /// In en, this message translates to:
  /// **'{kind} marked as paid from the payment SMS. Its reminders are off.'**
  String notifPaidBody(String kind);

  /// No description provided for @billPaidFromSmsHelp.
  ///
  /// In en, this message translates to:
  /// **'Marked paid from the payment confirmation SMS. Tap \"Mark as unpaid\" if that was a different bill.'**
  String get billPaidFromSmsHelp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
