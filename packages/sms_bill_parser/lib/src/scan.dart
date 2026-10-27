import 'models.dart';

/// An amount of money found in a message, in paise.
final class FoundAmount {
  const FoundAmount(this.paise, this.start, this.end);
  final int paise;
  final int start;
  final int end;
}

/// A date found in a message.
final class FoundDate {
  const FoundDate(this.date, this.start, this.end);
  final CalendarDate date;
  final int start;
  final int end;
}

// `Rs.`, `Rs`, `INR`, `₹`, optionally followed by `.`/`:` and spaces, then
// Indian (1,23,456.00) or western (123,456.00) grouping, or plain digits.
final RegExp _amountPattern = RegExp(
  r'(?<![a-z])(?:rs\.?|inr|₹)\s*[.:]?\s*'
  r'(\d{1,3}(?:,\d{2,3})+|\d+)(?:\.(\d{1,2}))?(?:\s*/-)?',
  caseSensitive: false,
);

/// Every amount with a currency marker in [text].
List<FoundAmount> findAmounts(String text) => [
  for (final m in _amountPattern.allMatches(text))
    FoundAmount(_toPaise(m.group(1)!, m.group(2)), m.start, m.end),
];

int _toPaise(String whole, String? fraction) {
  final rupees = int.parse(whole.replaceAll(',', ''));
  final paise = fraction == null ? 0 : int.parse(fraction.padRight(2, '0'));
  return rupees * 100 + paise;
}

const Map<String, int> _months = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

const String _monthNames =
    r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|'
    r'aug(?:ust)?|sept?(?:ember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)';

// 05/11/2026, 05-11-26, 5.11.2026 (Indian order: day first).
final RegExp _numericDate = RegExp(
  r'(?<![\d,.])(\d{1,2})([-/.])(\d{1,2})\2(\d{4}|\d{2})(?![\d,]|\.\d)',
);

// 2026-11-05.
final RegExp _isoDate = RegExp(r'(?<!\d)(\d{4})-(\d{2})-(\d{2})(?!\d)');

// 05-Nov-26, 5th Nov, 05 November 2026, 05NOV2026, 5th of Nov.
final RegExp _dayMonthDate = RegExp(
  r'(?<![\d.,])(\d{1,2})(?:st|nd|rd|th)?[\s\-/]*(?:of\s+)?'
  '$_monthNames'
  r"\b\.?(?:[\s\-/,']*(\d{4}|\d{2})(?![\d,:]))?",
  caseSensitive: false,
);

// 05NOV26 / 05NOV2026 with no separators (the \b above can't split these).
final RegExp _compactDate = RegExp(
  r'(?<![\d.,])(\d{2})'
  '$_monthNames'
  r'(\d{4}|\d{2})(?!\d)',
  caseSensitive: false,
);

// Nov 5, 2026 / November 5th.
final RegExp _monthDayDate = RegExp(
  '\\b$_monthNames'
  r'\.?\s+(\d{1,2})(?:st|nd|rd|th)?\b(?:,?\s*(\d{4})(?!\d))?',
  caseSensitive: false,
);

final RegExp _relativeDate = RegExp(
  r'\b(today|tomorrow|tmrw|in\s+(\d{1,2})\s+days?)\b',
  caseSensitive: false,
);

/// Every date in [text]. Dates without a year get the year that puts them
/// closest after [receivedOn] (allowing up to a month in the past, for
/// overdue reminders).
List<FoundDate> findDates(String text, CalendarDate receivedOn) {
  final found = <FoundDate>[];
  bool overlaps(int start, int end) =>
      found.any((d) => start < d.end && end > d.start);
  void add(int? year, int month, int day, int start, int end) {
    if (overlaps(start, end)) return;
    final resolvedYear = year ?? _inferYear(month, day, receivedOn);
    if (!CalendarDate.isValid(resolvedYear, month, day)) return;
    found.add(FoundDate(CalendarDate(resolvedYear, month, day), start, end));
  }

  for (final m in _isoDate.allMatches(text)) {
    add(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      m.start,
      m.end,
    );
  }
  for (final m in _compactDate.allMatches(text)) {
    add(
      _year(m.group(3)),
      _months[m.group(2)!.substring(0, 3).toLowerCase()]!,
      int.parse(m.group(1)!),
      m.start,
      m.end,
    );
  }
  for (final m in _dayMonthDate.allMatches(text)) {
    add(
      _year(m.group(3)),
      _months[m.group(2)!.substring(0, 3).toLowerCase()]!,
      int.parse(m.group(1)!),
      m.start,
      m.end,
    );
  }
  for (final m in _monthDayDate.allMatches(text)) {
    add(
      _year(m.group(3)),
      _months[m.group(1)!.substring(0, 3).toLowerCase()]!,
      int.parse(m.group(2)!),
      m.start,
      m.end,
    );
  }
  for (final m in _numericDate.allMatches(text)) {
    add(
      _year(m.group(4)),
      int.parse(m.group(3)!),
      int.parse(m.group(1)!),
      m.start,
      m.end,
    );
  }
  for (final m in _relativeDate.allMatches(text)) {
    final word = m.group(1)!.toLowerCase();
    final offset = word == 'today'
        ? 0
        : m.group(2) != null
        ? int.parse(m.group(2)!)
        : 1;
    if (overlaps(m.start, m.end)) continue;
    found.add(FoundDate(receivedOn.addDays(offset), m.start, m.end));
  }
  found.sort((a, b) => a.start - b.start);
  return found;
}

int? _year(String? text) {
  if (text == null) return null;
  final value = int.parse(text);
  return text.length == 2 ? 2000 + value : value;
}

int _inferYear(int month, int day, CalendarDate receivedOn) {
  for (final year in [receivedOn.year, receivedOn.year + 1]) {
    if (!CalendarDate.isValid(year, month, day)) continue;
    final candidate = CalendarDate(year, month, day);
    if (receivedOn.daysUntil(candidate) >= -31) return year;
  }
  return receivedOn.year + 1;
}

/// The last 4 characters of a card, loan, consumer, policy or phone number.
///
/// Only the tail is kept: it's enough to tell two cards apart and to match a
/// payment to its bill, and the app never stores full numbers.
String? findAccountRef(String text) {
  for (final pattern in _refPatterns) {
    final m = pattern.firstMatch(text);
    if (m == null) continue;
    final raw = m.group(1)!.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    // Prefer the trailing digits: `98XXXXXX10` → `10`, `BP00123456` → `3456`.
    final digits = RegExp(r'\d+$').firstMatch(raw)?.group(0) ?? raw;
    if (digits.length < 2) continue;
    return digits.length <= 4
        ? digits.toUpperCase()
        : digits.substring(digits.length - 4).toUpperCase();
  }
  return null;
}

final List<RegExp> _refPatterns = [
  // A keyword, an optional `no.`/`ID`, then the number, masked or not:
  // `Card XX4417`, `card ending 4417`, `A/c XXXX5521`, `CA No. 60012345678`,
  // `K No 2391000123`, `policy 00998877`, `user ID actuser123456`.
  RegExp(
    r'\b(?:card|a/c|acct|account|loan|ca|can|crn|consumer|service|usc|bp|'
    r'customer|connection|policy|subscriber|user|landline|number|k)'
    r'(?:\s*(?:no|number|id|num)\b)?\.?\s*(?:ending\s*(?:with|in)?)?\s*'
    r'[:\-#]?\s*([A-Z0-9][A-Z0-9*/-]*\d{2,})\b',
    caseSensitive: false,
  ),
  // `BOBCARD ending 7720`.
  RegExp(r'\bending\s*(?:with|in)?\s*[:\-]?\s*(\d{4,})', caseSensitive: false),
  // Standalone masked number: XX1234 / XXXXXXXXXXXX1234.
  RegExp(r'\b[x*]{2,}(\d{4})\b', caseSensitive: false),
  // Mobile numbers, full or masked: 9876543210, 98XXXXXX10.
  RegExp(r'(?<!\d)(?:\+?91[\s-]?)?([6-9][\dxX*]{7}\d{2})(?!\d)'),
];
