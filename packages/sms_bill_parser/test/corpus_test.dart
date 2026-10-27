import 'package:sms_bill_parser/sms_bill_parser.dart';
import 'package:test/test.dart';

import 'corpus/bill_corpus.dart';
import 'corpus/holdout_corpus.dart';
import 'corpus/payment_corpus.dart';

int? _paise(double? rupees) => rupees == null ? null : (rupees * 100).round();

void main() {
  const parser = BillSmsParser();

  test('corpus is big enough', () {
    expect(billCorpus.length, greaterThanOrEqualTo(60));
    expect(ignoredCorpus.length, greaterThanOrEqualTo(20));
  });

  group('bills', () {
    for (final (i, c) in [...billCorpus, ...holdoutBills].indexed) {
      test('#$i ${c.sender} ${c.kind.name}', () {
        final result = parser.parse(
          SmsInput(sender: c.sender, body: c.body, receivedAt: c.receivedAt),
        );
        expect(result, isA<BillNotice>(), reason: c.body);
        final bill = result as BillNotice;
        expect(bill.kind, c.kind, reason: 'kind');
        expect(bill.issuer.id, c.issuer, reason: 'issuer');
        expect(bill.dueDate.toString(), c.due, reason: 'due date');
        expect(bill.amountDue, _paise(c.amount), reason: 'amount');
        expect(bill.minimumDue, _paise(c.minimum), reason: 'minimum');
        expect(bill.accountRef, c.ref, reason: 'account ref');
      });
    }
  });

  group('not bills', () {
    for (final (i, c) in [
      ...ignoredCorpus,
      ...holdoutIgnored,
      ...notPaymentCorpus,
    ].indexed) {
      test('#$i ${c.sender} ${c.reason.name}', () {
        final result = parser.parse(
          SmsInput(sender: c.sender, body: c.body, receivedAt: c.receivedAt),
        );
        expect(result, isA<IgnoredSms>(), reason: '$result\n${c.body}');
        expect((result as IgnoredSms).reason, c.reason);
      });
    }
  });

  group('payments', () {
    for (final (i, c) in paymentCorpus.indexed) {
      test('#$i ${c.sender} ${c.kind.name}', () {
        final result = parser.parse(
          SmsInput(sender: c.sender, body: c.body, receivedAt: c.receivedAt),
        );
        expect(result, isA<PaymentNotice>(), reason: '$result\n${c.body}');
        final payment = result as PaymentNotice;
        expect(payment.kind, c.kind, reason: 'kind');
        expect(payment.issuer.id, c.issuer, reason: 'issuer');
        expect(payment.accountRef, c.ref, reason: 'account ref');
        expect(payment.amount, _paise(c.amount), reason: 'amount');
      });
    }
  });
}
