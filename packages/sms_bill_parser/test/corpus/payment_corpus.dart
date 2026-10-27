// Synthetic payment confirmations, in the style of Indian bank, biller and
// telco SMS. None of them is a real message.

import 'package:sms_bill_parser/sms_bill_parser.dart';

import 'bill_corpus.dart';

/// One message that must be read as a payment.
final class PaymentCase {
  const PaymentCase(
    this.sender,
    this.received,
    this.body, {
    required this.kind,
    required this.issuer,
    this.ref,
    this.amount,
  });

  final String sender;
  final String received;
  final String body;
  final BillKind kind;
  final String issuer;
  final String? ref;
  final double? amount;

  DateTime get receivedAt => DateTime.parse(received);
}

const List<PaymentCase> paymentCorpus = [
  PaymentCase(
    'VM-HDFCBK',
    '2026-10-20 10:00',
    'Payment of Rs.24,816.50 has been received towards your HDFC Bank '
        'Credit Card XX4417 on 20-Oct-26. Thank you.',
    kind: BillKind.creditCard,
    issuer: 'hdfc',
    ref: '4417',
    amount: 24816.50,
  ),
  PaymentCase(
    'VM-AIRTEL',
    '2026-10-20 10:00',
    'Thank you for the payment of Rs 599.00 for your Airtel postpaid '
        '98XXXXXX21. Your next bill date is 10-Nov-26.',
    kind: BillKind.mobilePostpaid,
    issuer: 'airtel',
    ref: '21',
    amount: 599,
  ),
  PaymentCase(
    'JD-JIOINF',
    '2026-10-29 10:00',
    'Recharge of Rs 349 successful for 70XXXXXX56. Plan valid till '
        '26-Nov-26.',
    kind: BillKind.prepaidRecharge,
    issuer: 'jio',
    ref: '56',
    amount: 349,
  ),
  PaymentCase(
    'VM-HDFCBK',
    '2026-10-07 10:00',
    'EMI of Rs.32,450 for HDFC Bank Home Loan A/c XXXXXXX5521 has been '
        'debited on 07-Oct-26.',
    kind: BillKind.loanEmi,
    issuer: 'hdfc',
    ref: '5521',
    amount: 32450,
  ),
  PaymentCase(
    'AD-ICICIB',
    '2026-10-25 10:00',
    'INR 8,412.00 credited to your ICICI Bank Credit Card XX9083 on '
        '25-Oct-26. Thank you.',
    kind: BillKind.creditCard,
    issuer: 'icici',
    ref: '9083',
    amount: 8412,
  ),
  PaymentCase(
    'VK-BESCOM',
    '2026-10-20 10:00',
    'BESCOM: Payment of Rs.1,436.00 for Account ID 7812345678 received on '
        '20-10-2026. Thank you.',
    kind: BillKind.electricity,
    issuer: 'bescom',
    ref: '5678',
    amount: 1436,
  ),
  PaymentCase(
    'VK-SBICRD-S',
    '2026-10-30 09:15',
    'We have received payment of Rs. 1,02,345.75 for your SBI Card ending '
        '2290 on 30/10/2026. Available limit: Rs 2,40,000.',
    kind: BillKind.creditCard,
    issuer: 'sbicard',
    ref: '2290',
    amount: 102345.75,
  ),
  PaymentCase(
    'AX-AXISBK-T',
    '2026-11-06 12:00',
    'Payment of INR 780.00 received on your Axis Bank Credit Card no. XX7651.'
        ' Total outstanding INR 14,820.00.',
    kind: BillKind.creditCard,
    issuer: 'axis',
    ref: '7651',
    amount: 780,
  ),
  PaymentCase(
    'JD-BFLEMI',
    '2026-11-02 11:00',
    'Bajaj Finance: EMI of Rs 3,499 for loan no. 4XXXXX8802 has been '
        'successfully collected. Thank you.',
    kind: BillKind.loanEmi,
    issuer: 'bajaj',
    ref: '8802',
    amount: 3499,
  ),
  PaymentCase(
    'VM-LICIND-S',
    '2026-10-26 18:00',
    'LIC: Premium of Rs.12,618.00 received for policy no. 512345678. Next '
        'due 28/10/2027.',
    kind: BillKind.insurance,
    issuer: 'lic',
    ref: '5678',
    amount: 12618,
  ),
  PaymentCase(
    'JD-TPDDLM',
    '2026-10-18 20:30',
    'Tata Power-DDL: Thanks for your payment of Rs 3,120.00 against CA No. '
        '60012345678.',
    kind: BillKind.electricity,
    issuer: 'tpddl',
    ref: '5678',
    amount: 3120,
  ),
  PaymentCase(
    'VK-VICARE',
    '2026-11-05 13:00',
    'Vi: Your bill payment of Rs 701.82 for 9876543210 is successful.',
    kind: BillKind.mobilePostpaid,
    issuer: 'vi',
    ref: '3210',
    amount: 701.82,
  ),
  PaymentCase(
    'VM-IGLGAS',
    '2026-10-15 09:00',
    'IGL: Payment of Rs 642.00 for PNG BP No. 5000123456 received '
        'successfully.',
    kind: BillKind.gas,
    issuer: 'igl',
    ref: '3456',
    amount: 642,
  ),
  PaymentCase(
    'AD-ACTFBR',
    '2026-10-09 22:00',
    'ACT Fibernet: Payment of Rs.1,049.00 for user ID actuser123456 '
        'processed. Thank you.',
    kind: BillKind.broadband,
    issuer: 'act',
    ref: '3456',
    amount: 1049,
  ),
];

/// Money in or out that is not a bill payment.
const List<IgnoredCase> notPaymentCorpus = [
  IgnoredCase(
    'JD-SBIINB',
    '2026-10-12 10:00',
    'Rs.500.00 credited to your A/c XX1234 from RAHUL S via UPI on 12Oct26.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'VM-KOTAKB',
    '2026-10-12 10:00',
    'Payment of Rs 2,000 received in your Kotak a/c XX7788 from PRIYA via '
        'IMPS.',
    IgnoreReason.paymentConfirmation,
  ),
];
