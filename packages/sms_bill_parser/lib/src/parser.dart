import 'models.dart';
import 'scan.dart';
import 'sender.dart';

RegExp _re(String pattern) => RegExp(pattern, caseSensitive: false);

final RegExp _otp = _re(
  r'\b(?:otp|one[\s-]?time[\s-]?pass(?:word|code)|verification code|'
  r'auth(?:entication)? code|security code)\b',
);
final RegExp _otpCode = RegExp(r'(?<![\d,.])\d{4,8}(?![\d,]|\.\d)');

final RegExp _promotion = _re(
  r'pre[\s-]?approved|apply now|congratulations|you have won|\bwin\b|'
  r'eligible for|\bavail\b|limited[\s-]period|instant (?:personal )?loan|'
  r'loan offer|special offer|exclusive offer|upgrade (?:your|to)|'
  r'lowest (?:interest|rate)|top[\s-]?up loan|get up ?to|flat \d+% off|'
  r'\bsale\b|hurry|use code|coupon|\bkyc\b',
);

/// Past-tense confirmations that money was received, not requested.
final RegExp _paymentConfirmation = _re(
  r'(?:payment|pymt|pmt|recharge|premium|emi)\b.{0,60}?'
  r'(?:has been |is |was )?(?:successfully )?'
  r'(?:received|credited|successful|success|processed|realised|realized|collected)|'
  r'(?:received|thank you for|thanks for)\s+(?:your |the )?(?:payment|pymt|recharge|premium)|'
  r'(?:emi|amount|rs\.?|inr)\b.{0,60}?(?:has been|is|was) (?:successfully )?'
  r'(?:debited|deducted|paid)|'
  r'credited to your\b[^.]{0,30}?\bcard',
);

/// "Ignore if already paid" and similar clauses, which must not make a
/// reminder look like a payment confirmation.
final RegExp _ignoreIfClause = _re(
  r'(?:please |kindly |pls )?(?:ignore|disregard)\b[^.]{0,20}?'
  r'\b(?:if|in case)\b[^.]*',
);

/// Every bill reminder says when: due, pay by, last date, expires, renew...
final RegExp _dueSignal = _re(
  r'\b(?:due|payable|pay(?:ment)? (?:by|before|on or before)|last date|'
  r'expir\w*|validity|valid till|renew\w*|presented|auto[\s-]?debit\w*|'
  r'will be (?:debited|deducted)|scheduled for|lapse\w*)\b',
);

/// Words that usually come right before a due date.
final RegExp _dueBefore = _re(
  r'\b(?:due|payable|pay(?:ment)?|paid|pay it|on or|valid|validity|expir\w*|'
  r'last date|deadline|debited|deducted|presented|auto[\s-]?debit\w*|'
  r'lapse\w*|disconnect\w*|renew\w*|before|by|till|upto|until|on)'
  r'\W{0,4}(?:\w+\W{1,3}){0,4}$',
);

/// Words that mark a date as something other than the due date.
final RegExp _notDueBefore = _re(
  r'\b(?:(?:statement|stmt|bill(?:ing)?|invoice|reading|txn|transaction)\s*'
  r'(?:date|dt|period|generated on|generated|dated|on)|generated on|'
  r'issued on|dated|from|since)\W{0,4}$',
);

final RegExp _minimumBefore = _re(
  r'(?:\bmin(?:imum)?\.?\s*(?:amt|amount|payment)?\.?\s*(?:due|payable)?|\bmad)'
  r'\W{0,4}$',
);

final RegExp _totalBefore = _re(
  r'(?:total\s*(?:amt|amount)?\.?\s*(?:due|outstanding|payable)?|'
  r'(?:amt|amount)\.?\s*(?:due|payable|of)|outstanding|payable|bill\s*(?:amt|amount|of|is|for)|'
  r'due\s*(?:amt|amount|of)|emi\s*(?:amt|amount)?\s*(?:of|is)?|'
  r'premium\s*(?:amt|amount)?\s*(?:of|is)?)\W{0,4}$',
);

/// Amounts that are not what the user has to pay.
final RegExp _otherAmountBefore = _re(
  r'\b(?:limit|avl|available|avbl|late\s*(?:fee|payment|charges?)|'
  r'(?:penalty|convenience|processing|delayed payment)\s*(?:fee|charges?)|'
  r'penalty|cashback|discount|save|reward|last payment|paid|unbilled)\b'
  r'[^.]{0,20}$',
);

final List<(RegExp, BillKind)> _kindPatterns = [
  (
    _re(r'credit\s*card|\bcc\b|card\s*(?:statement|stmt|a/c|ending|x+\d|no\b)'),
    BillKind.creditCard,
  ),
  (_re(r'premium|polic(?:y|ies)|insurance'), BillKind.insurance),
  (_re(r'\bemi\b|\bloan\b'), BillKind.loanEmi),
  (
    _re(r'electricity|\bpower\b|\bkwh\b|units consumed|energy bill|\bdiscom\b'),
    BillKind.electricity,
  ),
  (_re(r'\bwater\b|sewerage|jal board'), BillKind.water),
  (_re(r'\bgas\b|\bpng\b|\bscm\b'), BillKind.gas),
  (
    _re(r'broadband|fib(?:er|re)|wi-?fi|internet|\bftth\b|landline|xstream'),
    BillKind.broadband,
  ),
  (
    _re(
      r'post[\s-]?paid|mobile bill|bill for (?:your )?(?:mobile|number|airtel|jio|vi)',
    ),
    BillKind.mobilePostpaid,
  ),
  (
    _re(r'recharge|validity|(?:plan|pack)\s*(?:will\s*)?(?:expir|end)|prepaid'),
    BillKind.prepaidRecharge,
  ),
];

/// Reads Indian bill and due-date SMS.
///
/// [parse] never throws: anything it can't read becomes an [IgnoredSms].
final class BillSmsParser {
  const BillSmsParser();

  ParsedSms parse(SmsInput sms) {
    final senderId = businessSenderId(sms.sender);
    if (senderId == null) {
      return const IgnoredSms(IgnoreReason.notBusinessSender);
    }
    final body = sms.body.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (_otp.hasMatch(body) && _otpCode.hasMatch(body)) {
      return const IgnoredSms(IgnoreReason.otp);
    }
    if (_promotion.hasMatch(body)) {
      return const IgnoredSms(IgnoreReason.promotion);
    }
    if (_paymentConfirmation.hasMatch(body.replaceAll(_ignoreIfClause, ''))) {
      return const IgnoredSms(IgnoreReason.paymentConfirmation);
    }

    final sender = resolveSender(senderId, body);
    final kind = _kind(body, sender.kindHint);
    if (kind == null || !_dueSignal.hasMatch(body)) {
      return const IgnoredSms(IgnoreReason.notABill);
    }

    final receivedOn = CalendarDate.fromDateTime(sms.receivedAt);
    final dueDate = _dueDate(body, receivedOn);
    if (dueDate == null) return const IgnoredSms(IgnoreReason.noDueDate);

    final (total, minimum) = _amounts(body);
    if (total == null && kind != BillKind.prepaidRecharge) {
      return const IgnoredSms(IgnoreReason.noAmount);
    }

    return BillNotice(
      kind: kind,
      issuer: sender.issuer,
      accountRef: findAccountRef(body),
      amountDue: total,
      minimumDue: minimum,
      dueDate: dueDate,
      receivedAt: sms.receivedAt,
    );
  }

  BillKind? _kind(String body, BillKind? hint) {
    // A header that only ever sends one kind of bill wins, except that a
    // bank header may send card, loan or insurance messages.
    if (hint != null) return hint;
    for (final (pattern, kind) in _kindPatterns) {
      if (pattern.hasMatch(body)) return kind;
    }
    return null;
  }

  CalendarDate? _dueDate(String body, CalendarDate receivedOn) {
    final dates = findDates(body, receivedOn);
    if (dates.isEmpty) return null;
    FoundDate? best;
    for (final date in dates) {
      final before = body.substring(
        date.start < 45 ? 0 : date.start - 45,
        date.start,
      );
      if (_notDueBefore.hasMatch(before)) continue;
      if (_dueBefore.hasMatch(before)) {
        best = date;
        break;
      }
    }
    if (best != null) return best.date;
    // A single date that isn't a statement date is the due date.
    final rest = dates.where((d) {
      final before = body.substring(d.start < 45 ? 0 : d.start - 45, d.start);
      return !_notDueBefore.hasMatch(before);
    }).toList();
    return rest.length == 1 ? rest.single.date : null;
  }

  (int?, int?) _amounts(String body) {
    int? total;
    int? minimum;
    int? fallback;
    for (final amount in findAmounts(body)) {
      final before = body.substring(
        amount.start < 40 ? 0 : amount.start - 40,
        amount.start,
      );
      if (_minimumBefore.hasMatch(before)) {
        minimum ??= amount.paise;
      } else if (_totalBefore.hasMatch(before)) {
        total ??= amount.paise;
      } else if (_otherAmountBefore.hasMatch(before)) {
        continue;
      } else {
        fallback ??= amount.paise;
      }
    }
    return (total ?? fallback, minimum);
  }
}
