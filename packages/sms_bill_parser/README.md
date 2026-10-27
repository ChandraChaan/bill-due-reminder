# sms_bill_parser

Reads Indian bill and due-date SMS (credit card statements, loan EMIs, electricity, water, gas, postpaid and broadband bills, prepaid plan expiry, insurance premiums) and keeps a de-duplicated list of bills.

Pure Dart: no Flutter, no I/O, no network. Part of [DueDay](https://github.com/ChandraChaan/bill-due-reminder); not yet published on pub.dev.

```dart
import 'package:sms_bill_parser/sms_bill_parser.dart';

void main() {
  const parser = BillSmsParser();
  final result = parser.parse(SmsInput(
    sender: 'VM-HDFCBK',
    body: 'HDFC Bank Credit Card ending 4417: Total Amt Due Rs.24,816.50, '
        'Min Amt Due Rs.1,240.00, Due by 04-Nov-26.',
    receivedAt: DateTime(2026, 10, 16),
  ));

  switch (result) {
    case BillNotice(:final issuer, :final amountDue, :final dueDate):
      print('${issuer.name}: $amountDue paise due $dueDate');
      // HDFC Bank: 2481650 paise due 2026-11-04
    case IgnoredSms(:final reason):
      print('not a bill: ${reason.name}');
  }
}
```

- `businessSenderId(sender)`: the privacy gate. Returns the sender ID for Indian business headers (`VM-HDFCBK`, `JD-AIRTEL-S`) and null for phone numbers, names and promotional `-P` headers. Check it before reading a message.
- `BillSmsParser.parse`: returns a `BillNotice` (kind, issuer, last digits of the account, total and minimum due in paise, due date) or an `IgnoredSms` with the reason (OTP, promotion, payment confirmation, not a bill...). Never throws.
- `BillBook`: an immutable list of `TrackedBill`s. `addNotice` merges a statement and its reminders into one bill; `markPaid` / `markUnpaid`, monthly repeats for typed-in bills, monthly totals, JSON.
- `findAmounts`, `findDates`, `findAccountRef`: the building blocks, for `Rs.`/`INR`/`₹` amounts with Indian grouping and dates like `05-Nov-26`, `05/11/2026`, `5th Nov`, `Nov 5, 2026`, `tomorrow`.

Money is always an `int` of paise. Dates are `CalendarDate` (no time zone).

## Tests

`dart test` runs unit tests plus a corpus of 114 synthetic messages (`test/corpus/`) with the expected result for each. None of them is a real message.
