// Written after the parser was tuned on bill_corpus.dart, to measure how it
// does on phrasings it was not tuned for. Synthetic, like the main corpus.

import 'package:sms_bill_parser/sms_bill_parser.dart';

import 'bill_corpus.dart';

const List<BillCase> holdoutBills = [
  BillCase(
    'VM-HDFCBK-S',
    '2026-10-18 09:00',
    'HDFC Bank Card x1234: Stmt dt 17/10/26, Amt due INR 7,203.00, Min due '
        'INR 361.00, Pay before 06/11/26.',
    kind: BillKind.creditCard,
    issuer: 'hdfc',
    ref: '1234',
    amount: 7203,
    minimum: 361,
    due: '2026-11-06',
  ),
  BillCase(
    'AX-AXISBK-T',
    '2026-11-04 08:00',
    'Payment Reminder: Rs.15,600 is due on your Axis Bank Credit Card XX7651 '
        'in 4 days. Pay now to avoid charges.',
    kind: BillKind.creditCard,
    issuer: 'axis',
    ref: '7651',
    amount: 15600,
    due: '2026-11-08',
  ),
  BillCase(
    'JD-ICICIB-S',
    '2026-10-25 10:00',
    'Your ICICI Bank Credit Card XX9083 payment of INR 8,412.00 is overdue '
        'since 27-Oct-26? No - it is due on 27-Oct-26. Pay via iMobile.',
    kind: BillKind.creditCard,
    issuer: 'icici',
    ref: '9083',
    amount: 8412,
    due: '2026-10-27',
  ),
  BillCase(
    'VK-KOTAKB',
    '2026-11-01 09:00',
    'Dear Customer, your Kotak Bank loan EMI Rs 9,870.00 for Loan '
        'No.XXXXXX1290 is scheduled for 05-NOV-2026.',
    kind: BillKind.loanEmi,
    issuer: 'kotak',
    ref: '1290',
    amount: 9870,
    due: '2026-11-05',
  ),
  BillCase(
    'BX-CESCLT',
    '2026-10-09 10:00',
    'CESC: Electricity bill for Customer ID 31012345678, Amount: Rs. 2,210, '
        'Due Date: 24.10.2026',
    kind: BillKind.electricity,
    issuer: 'cesc',
    ref: '5678',
    amount: 2210,
    due: '2026-10-24',
  ),
  BillCase(
    'VM-APSPDC',
    '2026-10-06 11:00',
    'APSPDCL: Dear Consumer, bill amount Rs.845/- for Service No '
        '1122334455667. Pay by 20/10/2026 to avoid surcharge.',
    kind: BillKind.electricity,
    issuer: 'apspdcl',
    ref: '5667',
    amount: 845,
    due: '2026-10-20',
  ),
  BillCase(
    'AD-BSESYP',
    '2026-10-22 08:30',
    'BSES Yamuna: CA No 100234567 bill Rs 1,980 due tomorrow. Pay now via '
        'BSES app.',
    kind: BillKind.electricity,
    issuer: 'bsesyamuna',
    ref: '4567',
    amount: 1980,
    due: '2026-10-23',
  ),
  BillCase(
    'JM-AIRTEL',
    '2026-10-26 12:00',
    'Airtel: Bill amount of Rs. 1,249.00 for your postpaid number 98XXXXXX45 '
        'due on 2nd Nov. Pay on the Airtel Thanks app.',
    kind: BillKind.mobilePostpaid,
    issuer: 'airtel',
    ref: '45',
    amount: 1249,
    due: '2026-11-02',
  ),
  BillCase(
    'VK-JIOFBR-S',
    '2026-11-10 09:00',
    'JioFiber: Your plan expires on 13-Nov-2026. Pay Rs 1,178 to continue '
        'services.',
    kind: BillKind.broadband,
    issuer: 'jio',
    amount: 1178,
    due: '2026-11-13',
  ),
  BillCase(
    'JD-VICARE-S',
    '2026-10-29 19:00',
    'Vi: Your validity on 99XXXXXX12 ends today. Recharge now with Rs 349.',
    kind: BillKind.prepaidRecharge,
    issuer: 'vi',
    ref: '12',
    amount: 349,
    due: '2026-10-29',
  ),
  BillCase(
    'VM-LICIND-S',
    '2026-11-20 10:00',
    'LIC: Policy 512345678 premium Rs.12,618 due 28/11/2026. Grace period '
        'ends 28/12/2026.',
    kind: BillKind.insurance,
    issuer: 'lic',
    ref: '5678',
    amount: 12618,
    due: '2026-11-28',
  ),
  BillCase(
    'AD-MGLGAS-S',
    '2026-12-08 11:00',
    'Mahanagar Gas bill Rs 1,140 for CA 210012345678 is due on 24 Dec. Pay '
        'online.',
    kind: BillKind.gas,
    issuer: 'mgl',
    ref: '5678',
    amount: 1140,
    due: '2026-12-24',
  ),
  BillCase(
    'VK-SBICRD',
    '2026-12-12 08:00',
    'SBI Card XX2290: Total Amount Due Rs 3,500.00 Minimum Amount Due Rs '
        '175.00 Payment Due Date 01 Jan 2027',
    kind: BillKind.creditCard,
    issuer: 'sbicard',
    ref: '2290',
    amount: 3500,
    minimum: 175,
    due: '2027-01-01',
  ),
  BillCase(
    'JD-DJBWTR-S',
    '2026-10-12 10:00',
    'DJB: Your water bill Rs 1,020.00 (K No 2391000123) is pending. Last '
        'date: 30-10-2026.',
    kind: BillKind.water,
    issuer: 'djb',
    ref: '0123',
    amount: 1020,
    due: '2026-10-30',
  ),
  BillCase(
    'VM-STARHI-S',
    '2026-11-01 09:00',
    'Star Health: Policy 123456 expires on 15-Nov-26. Renewal premium '
        'Rs.21,894. Renew today.',
    kind: BillKind.insurance,
    issuer: 'starhealth',
    ref: '3456',
    amount: 21894,
    due: '2026-11-15',
  ),
  BillCase(
    'AD-IDFCFB-S',
    '2026-11-20 09:00',
    'IDFC FIRST Bank: Your credit card ending 6610 bill of INR 2,000.50 is '
        'due on Nov 23.',
    kind: BillKind.creditCard,
    issuer: 'idfcfirst',
    ref: '6610',
    amount: 2000.50,
    due: '2026-11-23',
  ),
];

const List<IgnoredCase> holdoutIgnored = [
  IgnoredCase(
    'VM-HDFCBK',
    '2026-10-12 10:00',
    'Your HDFC Bank Credit Card XX4417 limit is Rs 2,00,000. Available limit '
        'Rs 1,75,000 as on 12-Oct-26.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'JD-AIRTEL',
    '2026-10-12 10:00',
    'Get 50% off on Airtel Xstream Fiber installation. Book before 31-Oct. '
        'Use code FIBER50.',
    IgnoreReason.promotion,
  ),
  IgnoredCase(
    'VM-SBIINB',
    '2026-10-12 10:00',
    'Dear SBI user, 112233 is your OTP to complete the bill payment of Rs '
        '1,436. Do not share.',
    IgnoreReason.otp,
  ),
  IgnoredCase(
    'JM-ZOMATO',
    '2026-10-12 10:00',
    'Your Zomato order of Rs 450 is due for delivery by 9 PM today.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    '+918888888888',
    '2026-10-12 10:00',
    'Bhai, your share of the electricity bill is Rs 650, due 5th Nov.',
    IgnoreReason.notBusinessSender,
  ),
  IgnoredCase(
    'VM-AMAZON',
    '2026-10-12 10:00',
    'Your Amazon Pay Later bill of Rs 2,000 is due on 05-Nov-26. Get 5% '
        'cashback, limited period offer.',
    IgnoreReason.promotion,
  ),
];
