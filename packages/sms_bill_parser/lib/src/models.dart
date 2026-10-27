/// A calendar day with no time and no time zone, such as a bill's due date.
final class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate(this.year, this.month, this.day);

  /// The local calendar day of [dateTime].
  factory CalendarDate.fromDateTime(DateTime dateTime) =>
      CalendarDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `yyyy-mm-dd`.
  factory CalendarDate.parse(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      throw FormatException('Expected yyyy-mm-dd', value);
    }
    return CalendarDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  final int year;
  final int month;
  final int day;

  /// Whether [year]-[month]-[day] is a real day (no 31 November).
  static bool isValid(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    final d = DateTime.utc(year, month, day);
    return d.month == month && d.day == day;
  }

  DateTime get _utc => DateTime.utc(year, month, day);

  CalendarDate addDays(int days) =>
      CalendarDate.fromDateTime(_utc.add(Duration(days: days)));

  /// The same day [months] later, clamped to the end of shorter months
  /// (31 Jan + 1 month = 28/29 Feb).
  CalendarDate addMonths(int months) {
    final index = year * 12 + (month - 1) + months;
    final y = index ~/ 12;
    final m = index % 12 + 1;
    final lastDay = DateTime.utc(y, m + 1, 0).day;
    return CalendarDate(y, m, day > lastDay ? lastDay : day);
  }

  /// Whole days from this date to [other] (positive when [other] is later).
  int daysUntil(CalendarDate other) =>
      other._utc.difference(_utc).inHours ~/ 24;

  bool isBefore(CalendarDate other) => compareTo(other) < 0;
  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  /// Midnight at the start of this day in the device's local time zone.
  DateTime toLocalDateTime({int hour = 0, int minute = 0}) =>
      DateTime(year, month, day, hour, minute);

  @override
  int compareTo(CalendarDate other) =>
      (year * 10000 + month * 100 + day) -
      (other.year * 10000 + other.month * 100 + other.day);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `yyyy-mm-dd`.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

/// What kind of bill an SMS is about.
enum BillKind {
  creditCard,
  loanEmi,
  electricity,
  water,
  gas,
  mobilePostpaid,
  broadband,
  prepaidRecharge,
  insurance,

  /// Only for bills the user types in; the parser never returns it.
  other,
}

/// One SMS as it arrived: sender header, text and receive time.
final class SmsInput {
  const SmsInput({
    required this.sender,
    required this.body,
    required this.receivedAt,
  });

  /// The sender header, for example `VM-HDFCBK` or `JD-AIRTEL-S`.
  final String sender;
  final String body;
  final DateTime receivedAt;
}

/// The company that sent a bill, resolved from the sender header or the text.
final class Issuer {
  const Issuer(this.id, this.name);

  /// Stable lowercase key used to match reminders and payments, e.g. `hdfc`.
  final String id;

  /// Display name, e.g. `HDFC Bank`.
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Issuer && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Issuer($id, $name)';
}

/// The result of reading one SMS.
sealed class ParsedSms {
  const ParsedSms();
}

/// The SMS announces a bill or a due date.
final class BillNotice extends ParsedSms {
  const BillNotice({
    required this.kind,
    required this.issuer,
    required this.dueDate,
    required this.receivedAt,
    this.accountRef,
    this.amountDue,
    this.minimumDue,
  });

  final BillKind kind;
  final Issuer issuer;

  /// The last characters of the card, loan, consumer or phone number, never
  /// the full number. Usually 4 digits; masked phone numbers may give 2.
  final String? accountRef;

  /// Total amount due in paise. Null when the SMS gives no amount (prepaid
  /// plan expiry reminders often don't).
  final int? amountDue;

  /// Minimum amount due in paise (credit cards only).
  final int? minimumDue;

  final CalendarDate dueDate;
  final DateTime receivedAt;

  @override
  String toString() =>
      'BillNotice(${kind.name}, ${issuer.id}, ref: $accountRef, '
      'due: $amountDue, min: $minimumDue, on: $dueDate)';
}

/// The SMS confirms that a bill was paid: a card payment received, an EMI
/// debited, a bill payment or recharge that went through.
final class PaymentNotice extends ParsedSms {
  const PaymentNotice({
    required this.kind,
    required this.issuer,
    required this.receivedAt,
    this.accountRef,
    this.amount,
  });

  final BillKind kind;
  final Issuer issuer;

  /// Last digits of the card, loan, consumer or phone number paid for.
  final String? accountRef;

  /// Amount paid in paise, when the SMS says.
  final int? amount;

  final DateTime receivedAt;

  @override
  String toString() =>
      'PaymentNotice(${kind.name}, ${issuer.id}, ref: $accountRef, '
      'paid: $amount)';
}

/// Why an SMS did not produce a bill.
enum IgnoreReason {
  /// Not a bank/biller header (a phone number, or a promotional `-P` header).
  /// The text of these messages is never looked at.
  notBusinessSender,
  otp,
  promotion,

  /// Confirms a payment, but it isn't clear for what kind of bill.
  paymentConfirmation,
  notABill,
  noDueDate,
  noAmount,
}

/// The SMS is not a bill.
final class IgnoredSms extends ParsedSms {
  const IgnoredSms(this.reason);

  final IgnoreReason reason;

  @override
  String toString() => 'IgnoredSms(${reason.name})';
}
