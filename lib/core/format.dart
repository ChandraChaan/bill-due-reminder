import 'package:intl/intl.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../l10n/app_localizations.dart';

final NumberFormat _rupees = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);
final NumberFormat _wholeRupees = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// `₹1,23,456.50`, or `₹1,23,456` when there are no paise.
String formatRupees(int paise) => paise % 100 == 0
    ? _wholeRupees.format(paise ~/ 100)
    : _rupees.format(paise / 100);

/// `Wed 4 Nov`, with the year added when it isn't [today]'s year.
String formatDay(CalendarDate date, CalendarDate today) => DateFormat(
  date.year == today.year ? 'EEE d MMM' : 'EEE d MMM yyyy',
).format(date.toLocalDateTime());

/// `November`.
String formatMonth(int year, int month) =>
    DateFormat('MMMM').format(DateTime(year, month));

/// Parses what the user typed as an amount (`1,250`, `1250.5`) into paise.
int? parseRupees(String text) {
  final cleaned = text.replaceAll(RegExp(r'[,\s₹]'), '');
  final match = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(cleaned);
  if (match == null) return null;
  final paise =
      int.parse(match.group(1)!) * 100 +
      int.parse((match.group(2) ?? '0').padRight(2, '0'));
  return paise == 0 ? null : paise;
}

/// The amount as an editable string: `1250` or `1250.50`.
String editableRupees(int paise) => paise % 100 == 0
    ? '${paise ~/ 100}'
    : '${paise ~/ 100}.${(paise % 100).toString().padLeft(2, '0')}';

String kindLabel(AppLocalizations l10n, BillKind kind) => switch (kind) {
  BillKind.creditCard => l10n.kindCreditCard,
  BillKind.loanEmi => l10n.kindLoanEmi,
  BillKind.electricity => l10n.kindElectricity,
  BillKind.water => l10n.kindWater,
  BillKind.gas => l10n.kindGas,
  BillKind.mobilePostpaid => l10n.kindMobilePostpaid,
  BillKind.broadband => l10n.kindBroadband,
  BillKind.prepaidRecharge => l10n.kindPrepaidRecharge,
  BillKind.insurance => l10n.kindInsurance,
  BillKind.other => l10n.kindOther,
};
