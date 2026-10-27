import 'package:sms_bill_parser/sms_bill_parser.dart';
import 'package:test/test.dart';

const _parser = BillSmsParser();

BillNotice _notice(String sender, String received, String body) =>
    _parser.parse(
          SmsInput(
            sender: sender,
            body: body,
            receivedAt: DateTime.parse(received),
          ),
        )
        as BillNotice;

BillBook _read(List<BillNotice> notices) =>
    notices.fold(BillBook(), (book, n) => book.addNotice(n));

PaymentNotice _payment(String sender, String received, String body) =>
    _parser.parse(
          SmsInput(
            sender: sender,
            body: body,
            receivedAt: DateTime.parse(received),
          ),
        )
        as PaymentNotice;

void main() {
  final statement = _notice(
    'VM-HDFCBK',
    '2026-10-16 10:00',
    'HDFC Bank Credit Card ending 4417: Total Amt Due Rs.24,816.50, Min Amt '
        'Due Rs.1,240.00, Due by 04-Nov-26.',
  );
  final reminder = _notice(
    'AD-HDFCBK-S',
    '2026-11-01 09:30',
    'Reminder: Payment of Rs.20,000.00 on your HDFC Bank Credit Card XX4417 '
        'is due on 04/11/2026.',
  );
  final dueTomorrow = _notice(
    'VM-HDFCBK',
    '2026-11-03 09:30',
    'Your HDFC Bank Credit Card bill of Rs.20,000.00 is due tomorrow.',
  );

  group('dedup', () {
    test('statement and reminders for the same bill become one bill', () {
      final book = _read([statement, reminder, dueTomorrow]);
      expect(book.bills, hasLength(1));
      final bill = book.bills.single;
      expect(bill.noticeCount, 3);
      expect(bill.accountRef, '4417');
      expect(bill.dueDate, const CalendarDate(2026, 11, 4));
    });

    test('the newest message sets the amount', () {
      final bill = _read([statement, reminder]).bills.single;
      expect(bill.amountDue, 2000000);
      expect(bill.lastSeenAt, reminder.receivedAt.toUtc());
    });

    test('an older message read later does not overwrite newer amounts', () {
      final bill = _read([reminder, statement]).bills.single;
      expect(bill.amountDue, 2000000);
      expect(bill.minimumDue, 124000, reason: 'filled from the older one');
    });

    test('the same message twice is still one bill', () {
      expect(_read([statement, statement]).bills, hasLength(1));
    });

    test('different cards of the same bank stay separate', () {
      final other = _notice(
        'VM-HDFCBK',
        '2026-10-16 10:05',
        'HDFC Bank Credit Card ending 9001: Total Amt Due Rs.1,000.00, Due '
            'by 04-Nov-26.',
      );
      expect(_read([statement, other]).bills, hasLength(2));
    });

    test("next month's statement is a new bill", () {
      final next = _notice(
        'VM-HDFCBK',
        '2026-11-16 10:00',
        'HDFC Bank Credit Card ending 4417: Total Amt Due Rs.5,000.00, Due by '
            '04-Dec-26.',
      );
      expect(_read([statement, next]).bills, hasLength(2));
    });

    test('a loan EMI and a card bill from the same bank stay separate', () {
      final emi = _notice(
        'VM-HDFCBK',
        '2026-11-01 09:00',
        'EMI of Rs.32,450 for your HDFC Bank Home Loan A/c XXXXXXX4417 is due '
            'on 04-Nov-2026.',
      );
      expect(_read([statement, emi]).bills, hasLength(2));
    });

    test('a masked phone number matches the full one', () {
      expect(refsCompatible('21', '4321'), isTrue);
      expect(refsCompatible(null, '4321'), isTrue);
      expect(refsCompatible('1234', '4321'), isFalse);
    });

    test('a reminder for a bill already marked paid keeps it paid', () {
      final paidAt = DateTime.utc(2026, 10, 30);
      var book = _read([statement]);
      book = book.markPaid(book.bills.single.id, paidAt);
      book = book.addNotice(reminder);
      expect(book.bills.single.paidAt, paidAt);
    });
  });

  group('manual bills', () {
    TrackedBill rent({bool repeat = true}) => TrackedBill(
      id: 'm-1',
      kind: BillKind.other,
      issuerId: 'manual',
      name: 'Rent',
      amountDue: 1800000,
      dueDate: const CalendarDate(2026, 1, 31),
      source: BillSource.manual,
      firstSeenAt: DateTime.utc(2026),
      lastSeenAt: DateTime.utc(2026),
      repeatMonthly: repeat,
    );

    test('paying a monthly bill creates next month', () {
      final book = BillBook([
        rent(),
      ]).markPaid('m-1', DateTime.utc(2026, 1, 30));
      expect(book.bills, hasLength(2));
      final next = book.upcoming.single;
      expect(next.dueDate, const CalendarDate(2026, 2, 28));
      expect(next.amountDue, 1800000);
      expect(next.isPaid, isFalse);
      // Paying the copy chains on without piling up ids.
      final after = book.markPaid(next.id, DateTime.utc(2026, 2, 27));
      expect(after.upcoming.single.dueDate, const CalendarDate(2026, 3, 28));
      expect(after.upcoming.single.id, 'm-1@2026-03-28');
    });

    test('paying twice does not create two copies', () {
      final at = DateTime.utc(2026, 1, 30);
      final book = BillBook([rent()]).markPaid('m-1', at);
      expect(book.markUnpaid('m-1').markPaid('m-1', at).bills, hasLength(2));
    });

    test('a one-off bill does not repeat', () {
      final book = BillBook([
        rent(repeat: false),
      ]).markPaid('m-1', DateTime.utc(2026, 1, 30));
      expect(book.bills, hasLength(1));
      expect(book.markUnpaid('m-1').bills.single.isPaid, isFalse);
    });

    test('upsert edits in place and remove deletes', () {
      final book = BillBook([
        rent(),
      ]).upsert(rent().copyWith(name: 'House rent'));
      expect(book.bills.single.name, 'House rent');
      expect(book.remove('m-1').bills, isEmpty);
    });
  });

  group('lists and totals', () {
    final book = _read([statement]).upsert(
      TrackedBill(
        id: 'm-2',
        kind: BillKind.other,
        issuerId: 'manual',
        name: 'Maid',
        amountDue: 500000,
        dueDate: const CalendarDate(2026, 11, 1),
        source: BillSource.manual,
        firstSeenAt: DateTime.utc(2026),
        lastSeenAt: DateTime.utc(2026),
        paidAt: DateTime.utc(2026, 10, 31),
        paidBy: PaidBy.manual,
      ),
    );

    test('upcoming holds unpaid bills by due date, paid the rest', () {
      expect(book.upcoming.map((b) => b.name), ['HDFC Bank']);
      expect(book.paid.map((b) => b.name), ['Maid']);
    });

    test('monthly totals split paid and unpaid', () {
      expect(book.totalDueIn(2026, 11), 2481650 + 500000);
      expect(book.totalDueIn(2026, 11, paid: false), 2481650);
      expect(book.totalDueIn(2026, 11, paid: true), 500000);
      expect(book.totalDueIn(2026, 12), 0);
    });

    test('prune drops old paid bills only', () {
      expect(book.prune(const CalendarDate(2028, 1, 1)).bills, hasLength(1));
      expect(book.prune(const CalendarDate(2026, 12, 1)).bills, hasLength(2));
    });

    test('JSON round trip', () {
      for (final bill in book.bills) {
        expect(TrackedBill.fromJson(bill.toJson()), bill);
      }
    });
  });

  test('bill ids are stable and differ per bill', () {
    expect(billIdFor(statement), billIdFor(statement));
    expect(billIdFor(statement), billIdFor(reminder), reason: 'same bill');
    expect(billIdFor(statement), isNot(billIdFor(dueTomorrow)));
    expect(billIdFor(statement), startsWith('sms-'));
  });

  group('paid by SMS', () {
    PaymentNotice cardPayment(String amount, {String card = '4417'}) =>
        _payment(
          'VM-HDFCBK',
          '2026-10-28 10:00',
          'Payment of Rs.$amount has been received towards your HDFC Bank '
              'Credit Card XX$card. Thank you.',
        );

    test('a payment for the full amount marks the bill paid', () {
      final book = _read([statement]).applyPayment(cardPayment('24,816.50'));
      final bill = book.bills.single;
      expect(bill.isPaid, isTrue);
      expect(bill.paidBy, PaidBy.sms);
      expect(bill.paidAt, DateTime.parse('2026-10-28 10:00').toUtc());
    });

    test('paying at least the minimum due counts', () {
      expect(
        _read([statement]).applyPayment(cardPayment('1,240.00')).upcoming,
        isEmpty,
      );
    });

    test('paying less than the minimum does not', () {
      expect(
        _read([statement]).applyPayment(cardPayment('500.00')).upcoming,
        hasLength(1),
      );
    });

    test('a payment to another card does not', () {
      expect(
        _read([
          statement,
        ]).applyPayment(cardPayment('24,816.50', card: '9001')).upcoming,
        hasLength(1),
      );
    });

    test('a loan EMI debit does not pay the card bill', () {
      final emi = _payment(
        'VM-HDFCBK',
        '2026-10-28 10:00',
        'EMI of Rs.32,450 for HDFC Bank Home Loan A/c XXXXXXX4417 has been '
            'debited.',
      );
      expect(_read([statement]).applyPayment(emi).upcoming, hasLength(1));
    });

    test('the oldest unpaid bill of the account is paid first', () {
      final next = _notice(
        'VM-HDFCBK',
        '2026-11-16 10:00',
        'HDFC Bank Credit Card ending 4417: Total Amt Due Rs.5,000.00, Due by '
            '04-Dec-26.',
      );
      final payment = _payment(
        'VM-HDFCBK',
        '2026-11-20 10:00',
        'Payment of Rs.5,000.00 has been received towards your HDFC Bank '
            'Credit Card XX4417.',
      );
      final book = _read([statement, next]).applyPayment(payment);
      expect(book.upcoming.single.dueDate, const CalendarDate(2026, 12, 4));
    });

    test('a payment long after the due date is not matched', () {
      final late = _payment(
        'VM-HDFCBK',
        '2026-12-20 10:00',
        'Payment of Rs.24,816.50 has been received towards your HDFC Bank '
            'Credit Card XX4417.',
      );
      expect(_read([statement]).applyPayment(late).upcoming, hasLength(1));
    });

    test('a payment with no amount still matches', () {
      final payment = _payment(
        'JD-JIOINF',
        '2026-10-29 10:00',
        'Recharge successful for 70XXXXXX56. Enjoy your plan.',
      );
      final expiry = _notice(
        'JD-JIOINF-S',
        '2026-10-26 09:00',
        'Your Jio plan for 70XXXXXX56 will expire on 29-Oct-26. Recharge now.',
      );
      expect(_read([expiry]).applyPayment(payment).upcoming, isEmpty);
    });

    test('bills typed in by hand are never marked paid by SMS', () {
      final manual = TrackedBill(
        id: 'm-1',
        kind: BillKind.creditCard,
        issuerId: 'hdfc',
        name: 'HDFC card',
        accountRef: '4417',
        amountDue: 2481650,
        dueDate: const CalendarDate(2026, 11, 4),
        source: BillSource.manual,
        firstSeenAt: DateTime.utc(2026, 10, 16),
        lastSeenAt: DateTime.utc(2026, 10, 16),
      );
      expect(
        BillBook([manual]).applyPayment(cardPayment('24,816.50')).upcoming,
        hasLength(1),
      );
    });

    test('a later reminder for a bill paid by SMS keeps it paid', () {
      final book = _read([
        statement,
      ]).applyPayment(cardPayment('24,816.50')).addNotice(reminder);
      expect(book.bills.single.isPaid, isTrue);
      expect(book.bills.single.paidBy, PaidBy.sms);
    });
  });
}
