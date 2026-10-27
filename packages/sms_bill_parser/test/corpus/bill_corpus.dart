// Synthetic SMS written for these tests in the style of Indian bank, card,
// utility, telecom and insurance messages. None of them is a real message:
// names, amounts, dates and numbers are made up.

import 'package:sms_bill_parser/sms_bill_parser.dart';

/// One message that must produce a bill.
final class BillCase {
  const BillCase(
    this.sender,
    this.received,
    this.body, {
    required this.kind,
    required this.issuer,
    required this.due,
    this.ref,
    this.amount,
    this.minimum,
  });

  final String sender;
  final String received;
  final String body;
  final BillKind kind;
  final String issuer;
  final String due;
  final String? ref;
  final double? amount;
  final double? minimum;

  DateTime get receivedAt => DateTime.parse(received);
}

/// One message that must not produce a bill.
final class IgnoredCase {
  const IgnoredCase(this.sender, this.received, this.body, this.reason);

  final String sender;
  final String received;
  final String body;
  final IgnoreReason reason;

  DateTime get receivedAt => DateTime.parse(received);
}

const List<BillCase> billCorpus = [
  // ── Credit cards ──────────────────────────────────────────────────────
  BillCase(
    'VM-HDFCBK',
    '2026-10-16 10:12',
    'Statement for HDFC Bank Credit Card ending 4417 dated 15-Oct-26: '
        'Total Amt Due Rs.24,816.50, Min Amt Due Rs.1,240.00, '
        'Due by 04-Nov-26. Pay via NetBanking/App.',
    kind: BillKind.creditCard,
    issuer: 'hdfc',
    ref: '4417',
    amount: 24816.50,
    minimum: 1240,
    due: '2026-11-04',
  ),
  BillCase(
    'AD-HDFCBK-S',
    '2026-11-01 09:30',
    'Reminder: Payment of Rs.24,816.50 on your HDFC Bank Credit Card XX4417 '
        'is due on 04/11/2026. Kindly ignore if already paid.',
    kind: BillKind.creditCard,
    issuer: 'hdfc',
    ref: '4417',
    amount: 24816.50,
    due: '2026-11-04',
  ),
  BillCase(
    'JD-ICICIB',
    '2026-10-09 19:44',
    'ICICI Bank Credit Card XX9083 Statement is sent to your email. '
        'Total Amount Due: INR 8,412.00; Minimum Amount Due: INR 420.00. '
        'Due date: 27-Oct-2026.',
    kind: BillKind.creditCard,
    issuer: 'icici',
    ref: '9083',
    amount: 8412,
    minimum: 420,
    due: '2026-10-27',
  ),
  BillCase(
    'VK-SBICRD',
    '2026-10-12 08:05',
    'Your SBI Card ending 2290 e-statement is generated. Total Amt Due: '
        'Rs 1,02,345.75 Min Amt Due: Rs 5,117.00 Payment Due Date: 02/11/26',
    kind: BillKind.creditCard,
    issuer: 'sbicard',
    ref: '2290',
    amount: 102345.75,
    minimum: 5117,
    due: '2026-11-02',
  ),
  BillCase(
    'BX-SBICRD-S',
    '2026-11-01 11:00',
    'Dear Cardholder, payment of Rs.1,02,345.75 for SBI Card XX2290 is due '
        'tomorrow. Pay now to avoid late payment charges.',
    kind: BillKind.creditCard,
    issuer: 'sbicard',
    ref: '2290',
    amount: 102345.75,
    due: '2026-11-02',
  ),
  BillCase(
    'AX-AXISBK',
    '2026-10-20 13:15',
    'Axis Bank Credit Card no. XX7651 statement: Total due ₹15,600.00, '
        'minimum due ₹780.00, pay by 8th Nov. Ignore if paid.',
    kind: BillKind.creditCard,
    issuer: 'axis',
    ref: '7651',
    amount: 15600,
    minimum: 780,
    due: '2026-11-08',
  ),
  BillCase(
    'VM-KOTAKB-T',
    '2026-10-18 07:50',
    'Kotak Credit Card xx3302: Statement generated on 17/10/2026. Total '
        'amount due Rs.3,210.40 and minimum amount due Rs.200.00 payable on or '
        'before 06/11/2026.',
    kind: BillKind.creditCard,
    issuer: 'kotak',
    ref: '3302',
    amount: 3210.40,
    minimum: 200,
    due: '2026-11-06',
  ),
  BillCase(
    'JM-IDFCFB',
    '2026-10-05 12:00',
    'Your IDFC FIRST Bank Credit Card statement for card ending 6610 is '
        'ready. Total Amount Due INR 46,005.20 | Minimum Due INR 2,300.26 | '
        'Due Date Oct 23, 2026',
    kind: BillKind.creditCard,
    issuer: 'idfcfirst',
    ref: '6610',
    amount: 46005.20,
    minimum: 2300.26,
    due: '2026-10-23',
  ),
  BillCase(
    'VD-INDUSB',
    '2026-10-24 16:40',
    'IndusInd Bank Credit Card XXXX5528: Total Amount Due Rs 9,999.00, '
        'Minimum Amount Due Rs 500.00, Payment Due Date 12-11-2026.',
    kind: BillKind.creditCard,
    issuer: 'indusind',
    ref: '5528',
    amount: 9999,
    minimum: 500,
    due: '2026-11-12',
  ),
  BillCase(
    'VK-YESBNK',
    '2026-10-11 10:10',
    'YES BANK Credit Card ending 0042 statement dated 10OCT26. Total Due: '
        'INR 2,450.00 Min Due: INR 245.00 Due on 30OCT26.',
    kind: BillKind.creditCard,
    issuer: 'yes',
    ref: '0042',
    amount: 2450,
    minimum: 245,
    due: '2026-10-30',
  ),
  BillCase(
    'AD-RBLCRD',
    '2026-10-26 09:00',
    'Gentle reminder: Total amount due of Rs. 18,240 on your RBL Bank '
        'credit card XX8181 is payable by 29th October 2026.',
    kind: BillKind.creditCard,
    issuer: 'rbl',
    ref: '8181',
    amount: 18240,
    due: '2026-10-29',
  ),
  BillCase(
    'VM-AMEXIN',
    '2026-10-14 06:30',
    'Your American Express Card account ending 31005 has a statement '
        'balance of INR 61,230.85. Minimum payment due INR 3,061.55 by '
        'November 3, 2026.',
    kind: BillKind.creditCard,
    issuer: 'amex',
    ref: '1005',
    amount: 61230.85,
    minimum: 3061.55,
    due: '2026-11-03',
  ),
  BillCase(
    'JD-BOBCRD-S',
    '2026-10-19 14:20',
    'BOBCARD ending 7720: Total Amount Due Rs.5,600.00, Minimum Amount Due '
        'Rs.280.00. Payment due on 2026-11-07. Pay via bobcard app.',
    kind: BillKind.creditCard,
    issuer: 'bobcard',
    ref: '7720',
    amount: 5600,
    minimum: 280,
    due: '2026-11-07',
  ),
  BillCase(
    'VM-ONECRD',
    '2026-10-22 21:05',
    'OneCard statement is out! Total due: ₹12,349.00. Min due: ₹618.00. '
        'Due date: 11 Nov 2026. Card XX0904.',
    kind: BillKind.creditCard,
    issuer: 'onecard',
    ref: '0904',
    amount: 12349,
    minimum: 618,
    due: '2026-11-11',
  ),
  BillCase(
    'VK-AUBANK',
    '2026-10-27 08:15',
    'AU Credit Card XX4545: Your bill of Rs.7,780.00 is due today. Pay '
        'now through AU 0101 app to avoid late fee.',
    kind: BillKind.creditCard,
    issuer: 'au',
    ref: '4545',
    amount: 7780,
    due: '2026-10-27',
  ),
  BillCase(
    'AD-SCBANK',
    '2026-10-13 12:45',
    'Standard Chartered Credit Card XX1290: Total Amount Due Rs. 33,000.00 '
        'Minimum Amount Due Rs. 1,650.00 Due Date 02.11.2026',
    kind: BillKind.creditCard,
    issuer: 'sc',
    ref: '1290',
    amount: 33000,
    minimum: 1650,
    due: '2026-11-02',
  ),
  BillCase(
    'BP-ICICIB-S',
    '2026-12-20 10:00',
    'ICICI Bank Credit Card XX9083: Total Amount Due INR 4,100.00, '
        'Minimum Amount Due INR 205.00, Due Date 5th Jan.',
    kind: BillKind.creditCard,
    issuer: 'icici',
    ref: '9083',
    amount: 4100,
    minimum: 205,
    due: '2027-01-05',
  ),

  // ── Loans and EMIs ────────────────────────────────────────────────────
  BillCase(
    'VM-HDFCBK',
    '2026-10-01 09:00',
    'Dear Customer, EMI of Rs.32,450 for your HDFC Bank Home Loan A/c '
        'XXXXXXX5521 is due on 07-Oct-2026. Please maintain sufficient '
        'balance.',
    kind: BillKind.loanEmi,
    issuer: 'hdfc',
    ref: '5521',
    amount: 32450,
    due: '2026-10-07',
  ),
  BillCase(
    'JD-BFLEMI',
    '2026-10-28 18:00',
    'Your Bajaj Finance EMI of Rs 3,499 for loan no. 4XXXXX8802 will be '
        'presented on 02-Nov-26. Keep balance in your bank account.',
    kind: BillKind.loanEmi,
    issuer: 'bajaj',
    ref: '8802',
    amount: 3499,
    due: '2026-11-02',
  ),
  BillCase(
    'VK-TATACP',
    '2026-10-29 10:30',
    'Tata Capital: Your personal loan EMI of INR 11,207.00 for A/c '
        'ending 3390 is due on 05/11/2026. Ignore if paid.',
    kind: BillKind.loanEmi,
    issuer: 'tatacapital',
    ref: '3390',
    amount: 11207,
    due: '2026-11-05',
  ),
  BillCase(
    'AD-HDBFSL',
    '2026-10-30 08:00',
    'Dear Customer, your EMI of Rs.2,150/- for Loan A/C XXXX7710 is due '
        'on 3rd Nov. Kindly keep funds ready. HDB Financial Services',
    kind: BillKind.loanEmi,
    issuer: 'hdbfs',
    ref: '7710',
    amount: 2150,
    due: '2026-11-03',
  ),
  BillCase(
    'VM-LICHFL',
    '2026-10-25 11:11',
    'LIC HFL: EMI of Rs.27,800 against loan account XXXXXXXX0412 will be '
        'auto-debited on 10/11/2026.',
    kind: BillKind.loanEmi,
    issuer: 'lichfl',
    ref: '0412',
    amount: 27800,
    due: '2026-11-10',
  ),
  BillCase(
    'JM-ICICIB',
    '2026-10-31 09:45',
    'ICICI Bank: EMI of INR 6,532 for your Personal Loan XX6017 is due '
        'on 04-Nov-26. Ensure sufficient balance in your account to avoid '
        'charges.',
    kind: BillKind.loanEmi,
    issuer: 'icici',
    ref: '6017',
    amount: 6532,
    due: '2026-11-04',
  ),
  BillCase(
    'VD-AXISBK-S',
    '2026-11-02 07:30',
    'Axis Bank Auto Loan a/c XX2384: EMI amount Rs 14,900 due on 5 '
        'November 2026. Please keep sufficient balance.',
    kind: BillKind.loanEmi,
    issuer: 'axis',
    ref: '2384',
    amount: 14900,
    due: '2026-11-05',
  ),
  BillCase(
    'BX-MUTHUT',
    '2026-10-26 15:00',
    'Muthoot Finance: Interest of Rs.4,215 on your gold loan no. '
        'GL00098821 is due on 31-10-2026. Pay at branch or online.',
    kind: BillKind.loanEmi,
    issuer: 'muthoot',
    ref: '8821',
    amount: 4215,
    due: '2026-10-31',
  ),

  // ── Electricity ───────────────────────────────────────────────────────
  BillCase(
    'VM-BESCOM',
    '2026-10-08 10:00',
    'BESCOM: Bill for Account ID 7812345678 for Oct-2026 is Rs.1,436.00. '
        'Due date 22-10-2026. Pay online at bescom.co.in',
    kind: BillKind.electricity,
    issuer: 'bescom',
    ref: '5678',
    amount: 1436,
    due: '2026-10-22',
  ),
  BillCase(
    'JD-MSEDCL',
    '2026-10-10 09:20',
    'MSEDCL: Dear consumer, your electricity bill for consumer no. '
        '170012345671 of Rs. 2,890 for 282 units is due on 30/10/2026. Pay '
        'before due date to get prompt payment discount.',
    kind: BillKind.electricity,
    issuer: 'msedcl',
    ref: '5671',
    amount: 2890,
    due: '2026-10-30',
  ),
  BillCase(
    'AD-TPDDLM',
    '2026-10-06 12:30',
    'Tata Power-DDL: Bill of Rs 3,120.00 for CA No. 60012345678 generated. '
        'Due date: 21-Oct-2026. Pay via Tata Power-DDL app.',
    kind: BillKind.electricity,
    issuer: 'tpddl',
    ref: '5678',
    amount: 3120,
    due: '2026-10-21',
  ),
  BillCase(
    'VK-BSESRP',
    '2026-10-07 18:10',
    'BSES Rajdhani: Your electricity bill for CA 151234567 is Rs.2,045.00, '
        'due on 23/10/26.',
    kind: BillKind.electricity,
    issuer: 'bsesrajdhani',
    ref: '4567',
    amount: 2045,
    due: '2026-10-23',
  ),
  BillCase(
    'JM-ADANIE-S',
    '2026-10-12 07:00',
    'Adani Electricity: Bill amount Rs.4,880.00 for Account No. '
        '100012349876 is due on 28 Oct 2026. Pay on time and avoid delayed '
        'payment charges.',
    kind: BillKind.electricity,
    issuer: 'adanielec',
    ref: '9876',
    amount: 4880,
    due: '2026-10-28',
  ),
  BillCase(
    'TM-TNEBLT',
    '2026-10-03 11:00',
    'TNPDCL: Service No. 0471234567, amount Rs.640 for 210 units. Last '
        'date for payment 17-10-2026.',
    kind: BillKind.electricity,
    issuer: 'tneb',
    ref: '4567',
    amount: 640,
    due: '2026-10-17',
  ),
  BillCase(
    'VM-TSSPDC',
    '2026-10-04 13:40',
    'TGSPDCL Bill: USC No 112233445, units 156, Bill Amt Rs.1,018.00, '
        'Due Dt 18/10/2026.',
    kind: BillKind.electricity,
    issuer: 'tgspdcl',
    ref: '3445',
    amount: 1018,
    due: '2026-10-18',
  ),
  BillCase(
    'AD-KSEBLT',
    '2026-10-09 09:00',
    'KSEB: Consumer No 1155800012345, bill amount Rs 1,262 for the period '
        'ending 08-10-2026. Due on 19-10-2026 for payment without fine.',
    kind: BillKind.electricity,
    issuer: 'kseb',
    ref: '2345',
    amount: 1262,
    due: '2026-10-19',
  ),
  BillCase(
    'VK-UPPCLM',
    '2026-10-15 10:25',
    'UPPCL: Electricity bill for account 2384000011 is ₹1,712. Please pay '
        'by 25-Oct-26 to avoid disconnection.',
    kind: BillKind.electricity,
    issuer: 'uppcl',
    ref: '0011',
    amount: 1712,
    due: '2026-10-25',
  ),
  BillCase(
    'JD-TATAPW',
    '2026-10-11 12:00',
    'Tata Power: Your electricity bill of Rs. 3,456.78 for CA No. '
        '900001234567 is due on Oct 26, 2026.',
    kind: BillKind.electricity,
    issuer: 'tatapower',
    ref: '4567',
    amount: 3456.78,
    due: '2026-10-26',
  ),

  // ── Water ─────────────────────────────────────────────────────────────
  BillCase(
    'VM-DJBWTR',
    '2026-10-02 10:00',
    'Delhi Jal Board: Water bill for K No 2391000123 is Rs.786.00. Pay by '
        '20-10-2026.',
    kind: BillKind.water,
    issuer: 'djb',
    ref: '0123',
    amount: 786,
    due: '2026-10-20',
  ),
  BillCase(
    'JM-BWSSBB',
    '2026-10-06 08:30',
    'BWSSB: RR No. W12345 water charges Rs 524 for Sep-26. Due on 20th '
        'Oct.',
    kind: BillKind.water,
    issuer: 'bwssb',
    amount: 524,
    due: '2026-10-20',
  ),
  BillCase(
    'AD-HMWSSB',
    '2026-10-05 17:00',
    'HMWSSB: Water bill for CAN 012345678 is Rs.390.00, due on 15/10/2026. '
        'Pay online.',
    kind: BillKind.water,
    issuer: 'hmwssb',
    ref: '5678',
    amount: 390,
    due: '2026-10-15',
  ),

  // ── Piped gas ─────────────────────────────────────────────────────────
  BillCase(
    'VM-IGLGAS',
    '2026-10-04 09:10',
    'IGL: Your PNG bill for BP No. 5000123456 is Rs 642.00. Due Date: '
        '19-Oct-2026. Pay via IGL Connect app.',
    kind: BillKind.gas,
    issuer: 'igl',
    ref: '3456',
    amount: 642,
    due: '2026-10-19',
  ),
  BillCase(
    'JD-MGLGAS',
    '2026-10-09 11:00',
    'Mahanagar Gas: Bill of Rs.1,084.00 for CA 210012345678 generated on '
        '08/10/2026. Due on 24/10/2026.',
    kind: BillKind.gas,
    issuer: 'mgl',
    ref: '5678',
    amount: 1084,
    due: '2026-10-24',
  ),
  BillCase(
    'VK-GGLGAS',
    '2026-10-14 10:00',
    'Gujarat Gas: Gas bill amount INR 512 for customer ID 7000456789 due on '
        '28.10.2026.',
    kind: BillKind.gas,
    issuer: 'gujaratgas',
    ref: '6789',
    amount: 512,
    due: '2026-10-28',
  ),
  BillCase(
    'AD-ATGLGS',
    '2026-10-16 09:00',
    'Adani Total Gas: Rs.880 bill for customer no 4100098765 is due on '
        '30-Oct-26.',
    kind: BillKind.gas,
    issuer: 'adanigas',
    ref: '8765',
    amount: 880,
    due: '2026-10-30',
  ),

  // ── Postpaid mobile ───────────────────────────────────────────────────
  BillCase(
    'VM-AIRTEL',
    '2026-10-12 10:00',
    'Your Airtel postpaid bill for 98XXXXXX21 of Rs.599.00 is due on '
        '30-Oct-2026. Pay on Airtel Thanks app.',
    kind: BillKind.mobilePostpaid,
    issuer: 'airtel',
    ref: '21',
    amount: 599,
    due: '2026-10-30',
  ),
  BillCase(
    'JD-JIOINF',
    '2026-10-18 09:00',
    'Jio Postpaid: Your bill of Rs 449.00 for Jio number 70XXXXXX56 is '
        'generated. Pay by 07-11-2026 to continue uninterrupted services.',
    kind: BillKind.mobilePostpaid,
    issuer: 'jio',
    ref: '56',
    amount: 449,
    due: '2026-11-07',
  ),
  BillCase(
    'VK-VICARE',
    '2026-10-21 12:00',
    'Vi Postpaid: Bill of Rs 701.82 for 9876543210 due on 08-Nov-26. Pay '
        'via Vi App.',
    kind: BillKind.mobilePostpaid,
    issuer: 'vi',
    ref: '3210',
    amount: 701.82,
    due: '2026-11-08',
  ),
  BillCase(
    'BZ-BSNLIN',
    '2026-10-07 12:00',
    'BSNL: Your mobile bill for 94XXXXXX88 is Rs 399.00. Last date of '
        'payment 25/10/2026.',
    kind: BillKind.mobilePostpaid,
    issuer: 'bsnl',
    ref: '88',
    amount: 399,
    due: '2026-10-25',
  ),

  // ── Broadband ─────────────────────────────────────────────────────────
  BillCase(
    'VM-AIRXTM',
    '2026-10-03 10:00',
    'Airtel Xstream Fiber bill of Rs 1,178.82 for account 2010123456 is '
        'due on 15-Oct-26. Pay now on Airtel Thanks.',
    kind: BillKind.broadband,
    issuer: 'airtel',
    ref: '3456',
    amount: 1178.82,
    due: '2026-10-15',
  ),
  BillCase(
    'JD-JIOFBR',
    '2026-10-10 10:00',
    'JioFiber: Bill of ₹999 for account 0123456789 is due on 20th Oct '
        '2026. Pay via MyJio.',
    kind: BillKind.broadband,
    issuer: 'jio',
    ref: '6789',
    amount: 999,
    due: '2026-10-20',
  ),
  BillCase(
    'AD-ACTFBR',
    '2026-10-01 07:00',
    'ACT Fibernet: Invoice for user ID actuser123456 for Rs.1,049.00 is '
        'generated. Due date 10/10/2026.',
    kind: BillKind.broadband,
    issuer: 'act',
    ref: '3456',
    amount: 1049,
    due: '2026-10-10',
  ),
  BillCase(
    'VK-HTHWAY',
    '2026-10-20 09:00',
    'Hathway Broadband: Rs.708.00 due for your account 1122334455 on '
        '28/10/2026. Renew now to avoid suspension.',
    kind: BillKind.broadband,
    issuer: 'hathway',
    ref: '4455',
    amount: 708,
    due: '2026-10-28',
  ),
  BillCase(
    'JM-EXCITL',
    '2026-10-26 08:00',
    'Excitel: Your internet plan of Rs 499 will expire on 29-Oct-2026. '
        'Renew to keep surfing.',
    kind: BillKind.broadband,
    issuer: 'excitel',
    amount: 499,
    due: '2026-10-29',
  ),
  BillCase(
    'BZ-BSNLIN-S',
    '2026-10-08 10:00',
    'BSNL Bharat Fibre: bill for landline 080XXXX7788 of Rs 1,032 is due on '
        '24-10-2026.',
    kind: BillKind.broadband,
    issuer: 'bsnl',
    ref: '7788',
    amount: 1032,
    due: '2026-10-24',
  ),

  // ── Prepaid recharge expiry ───────────────────────────────────────────
  BillCase(
    'JD-JIOINF-S',
    '2026-10-26 09:00',
    'Your Jio plan for 70XXXXXX56 will expire on 29-Oct-26. Recharge now '
        'with Rs 349 for 28 days.',
    kind: BillKind.prepaidRecharge,
    issuer: 'jio',
    ref: '56',
    amount: 349,
    due: '2026-10-29',
  ),
  BillCase(
    'VM-AIRTEL-S',
    '2026-10-27 18:00',
    'Your Airtel pack validity ends tomorrow. Recharge now on Airtel '
        'Thanks app to keep enjoying unlimited calls.',
    kind: BillKind.prepaidRecharge,
    issuer: 'airtel',
    due: '2026-10-28',
  ),
  BillCase(
    'VK-VIINFO',
    '2026-10-20 10:00',
    'Vi: Your prepaid plan on 99XXXXXX12 expires in 3 days. Recharge with '
        'Rs.299 to stay connected.',
    kind: BillKind.prepaidRecharge,
    issuer: 'vi',
    ref: '12',
    amount: 299,
    due: '2026-10-23',
  ),
  BillCase(
    'BZ-BSNLIN',
    '2026-10-15 12:00',
    'BSNL: Validity of your prepaid number 94XXXXXX88 expires on 18/10/2026.'
        ' Recharge now.',
    kind: BillKind.prepaidRecharge,
    issuer: 'bsnl',
    ref: '88',
    due: '2026-10-18',
  ),

  // ── Insurance premiums ────────────────────────────────────────────────
  BillCase(
    'VM-LICIND',
    '2026-10-05 10:00',
    'LIC: Premium of Rs.12,618.00 for policy no. 512345678 is due on '
        '28/10/2026. Pay online at licindia.in.',
    kind: BillKind.insurance,
    issuer: 'lic',
    ref: '5678',
    amount: 12618,
    due: '2026-10-28',
  ),
  BillCase(
    'JD-HDFCLI',
    '2026-10-12 09:00',
    'HDFC Life: Renewal premium of INR 25,000 for Policy No 21234567 is due '
        'on 01-Nov-2026. Pay before due date to keep your cover active.',
    kind: BillKind.insurance,
    issuer: 'hdfclife',
    ref: '4567',
    amount: 25000,
    due: '2026-11-01',
  ),
  BillCase(
    'AD-IPRULI',
    '2026-10-17 11:30',
    'ICICI Pru Life: Premium of Rs 8,450 for policy 00998877 is due on '
        '5th Nov 2026.',
    kind: BillKind.insurance,
    issuer: 'iciciprulife',
    ref: '8877',
    amount: 8450,
    due: '2026-11-05',
  ),
  BillCase(
    'VK-SBILIF',
    '2026-10-18 10:00',
    'SBI Life: Your policy 1C123456 premium of ₹18,300.00 is due on '
        '12-11-2026. Grace period applies.',
    kind: BillKind.insurance,
    issuer: 'sbilife',
    ref: '3456',
    amount: 18300,
    due: '2026-11-12',
  ),
  BillCase(
    'JM-STARHI',
    '2026-10-22 09:00',
    'Star Health: Your health insurance policy P/123456/01/2026/004321 '
        'premium Rs.21,894 is due for renewal on 15/11/2026. Renew online.',
    kind: BillKind.insurance,
    issuer: 'starhealth',
    ref: '4321',
    amount: 21894,
    due: '2026-11-15',
  ),
  BillCase(
    'VM-NIVABU-S',
    '2026-10-25 08:00',
    'Niva Bupa: Renewal premium Rs 14,560 for policy 31234567 is due on '
        '09 Nov 2026. Renew to continue cover.',
    kind: BillKind.insurance,
    issuer: 'nivabupa',
    ref: '4567',
    amount: 14560,
    due: '2026-11-09',
  ),
  BillCase(
    'AD-TATAAI',
    '2026-10-28 10:00',
    'Tata AIA Life: Premium amount Rs. 6,000.00 for policy no U123456789 '
        'is due on 10-Nov-26.',
    kind: BillKind.insurance,
    issuer: 'tataaia',
    ref: '6789',
    amount: 6000,
    due: '2026-11-10',
  ),

  // ── Unknown senders still work from the text ──────────────────────────
  BillCase(
    'VM-CITYBL',
    '2026-10-10 10:00',
    'City Municipal Corporation: Water charges of Rs 1,250 for connection '
        'no. 44556677 are due on 31-10-2026.',
    kind: BillKind.water,
    issuer: 'citybl',
    ref: '6677',
    amount: 1250,
    due: '2026-10-31',
  ),
  BillCase(
    'JD-FEDBNK',
    '2026-10-21 10:00',
    'Federal Bank Credit Card XX6060: Total amount due Rs 1,23,456.00 '
        'Minimum due Rs 6,173.00 Due date 10/11/2026',
    kind: BillKind.creditCard,
    issuer: 'federal',
    ref: '6060',
    amount: 123456,
    minimum: 6173,
    due: '2026-11-10',
  ),
];

const List<IgnoredCase> ignoredCorpus = [
  // ── Personal and promotional senders: the text is never read ──────────
  IgnoredCase(
    '+919876543210',
    '2026-10-12 10:00',
    'Hey, the electricity bill of Rs 1,200 is due on 15th, can you pay it?',
    IgnoreReason.notBusinessSender,
  ),
  IgnoredCase(
    '9876543210',
    '2026-10-12 10:00',
    'Rent of Rs.18,000 due on 5th Nov. Thanks!',
    IgnoreReason.notBusinessSender,
  ),
  IgnoredCase(
    'VM-HDFCBK-P',
    '2026-10-12 10:00',
    'Your credit card bill of Rs 5,000 is due on 05-Nov-26.',
    IgnoreReason.notBusinessSender,
  ),
  IgnoredCase(
    'Mom',
    '2026-10-12 10:00',
    'Pay the gas bill Rs 800 by tomorrow',
    IgnoreReason.notBusinessSender,
  ),

  // ── OTPs ──────────────────────────────────────────────────────────────
  IgnoredCase(
    'VM-HDFCBK',
    '2026-10-12 10:00',
    '483920 is the OTP for payment of Rs 24,816.50 to HDFC Bank Credit Card '
        'XX4417. Valid till 10:05. Do not share it with anyone.',
    IgnoreReason.otp,
  ),
  IgnoredCase(
    'JD-ICICIB',
    '2026-10-12 10:00',
    'Dear Customer, OTP is 772104 for txn of INR 8,412.00 on ICICI Bank '
        'Credit Card XX9083 at BILLDESK on 12-Oct-26.',
    IgnoreReason.otp,
  ),
  IgnoredCase(
    'VM-AIRTEL',
    '2026-10-12 10:00',
    'Your one time password to pay your Airtel bill of Rs 599 is 5521. It '
        'expires in 10 minutes.',
    IgnoreReason.otp,
  ),
  IgnoredCase(
    'AD-SBICRD',
    '2026-10-12 10:00',
    'Use verification code 019283 to register your SBI Card for autopay.',
    IgnoreReason.otp,
  ),

  // ── Promotions ────────────────────────────────────────────────────────
  IgnoredCase(
    'VK-HDFCBK',
    '2026-10-12 10:00',
    'Congratulations! You are pre-approved for a Personal Loan of up to '
        'Rs.5,00,000 at 10.5% p.a. Offer valid till 31-Oct-26. Apply now.',
    IgnoreReason.promotion,
  ),
  IgnoredCase(
    'JD-BAJFIN',
    '2026-10-12 10:00',
    'Instant loan of Rs 2,00,000 credited in 30 mins! EMI starting Rs 999. '
        'Hurry, offer ends 30/10/2026.',
    IgnoreReason.promotion,
  ),
  IgnoredCase(
    'VM-AIRTEL',
    '2026-10-12 10:00',
    'Upgrade to Airtel Black and get up to 3 connections in one bill of Rs '
        '1,499. Limited period offer till 15-Nov.',
    IgnoreReason.promotion,
  ),
  IgnoredCase(
    'AD-JIOINF',
    '2026-10-12 10:00',
    'Recharge with Rs 349 and win a chance to get cashback. Use code JIO50 '
        'before 05-Nov-26.',
    IgnoreReason.promotion,
  ),
  IgnoredCase(
    'VM-AXISBK',
    '2026-10-12 10:00',
    'You are eligible for a credit limit increase to Rs 3,00,000 on your '
        'Axis Bank Credit Card XX7651. Reply YES by 31-Oct-26.',
    IgnoreReason.promotion,
  ),
  IgnoredCase(
    'JM-KOTAKB',
    '2026-10-12 10:00',
    'Convert your purchase of Rs 25,000 to easy EMI on Kotak Credit Card '
        'and avail lowest interest. Offer valid till 30-11-2026.',
    IgnoreReason.promotion,
  ),

  // ── Transaction alerts and payment confirmations ──────────────────────
  IgnoredCase(
    'VM-HDFCBK',
    '2026-10-12 10:00',
    'Rs.2,499.00 spent on HDFC Bank Credit Card XX4417 at AMAZON on '
        '2026-10-12:10:00:00. Avl Lmt: Rs.1,12,000.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'JD-SBIINB',
    '2026-10-12 10:00',
    'Your A/c XX1234 is debited by Rs.500.00 on 12Oct26 towards UPI ref '
        '629912345678. If not you, call 1800111109.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'VM-HDFCBK',
    '2026-10-20 10:00',
    'Payment of Rs.24,816.50 has been received towards your HDFC Bank '
        'Credit Card XX4417 on 20-Oct-26. Thank you.',
    IgnoreReason.paymentConfirmation,
  ),
  IgnoredCase(
    'VM-AIRTEL',
    '2026-10-20 10:00',
    'Thank you for the payment of Rs 599.00 for your Airtel postpaid '
        '98XXXXXX21. Your next bill date is 10-Nov-26.',
    IgnoreReason.paymentConfirmation,
  ),
  IgnoredCase(
    'JD-JIOINF',
    '2026-10-29 10:00',
    'Recharge of Rs 349 successful for 70XXXXXX56. Plan valid till '
        '26-Nov-26.',
    IgnoreReason.paymentConfirmation,
  ),
  IgnoredCase(
    'VM-HDFCBK',
    '2026-10-07 10:00',
    'EMI of Rs.32,450 for HDFC Bank Home Loan A/c XXXXXXX5521 has been '
        'debited on 07-Oct-26.',
    IgnoreReason.paymentConfirmation,
  ),

  // ── Other service messages ────────────────────────────────────────────
  IgnoredCase(
    'VM-BESCOM',
    '2026-10-12 10:00',
    'BESCOM: Power supply will be interrupted in your area on 14-Oct-26 '
        'from 10 AM to 2 PM for maintenance.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'AD-ICICIB',
    '2026-10-12 10:00',
    'Your ICICI Bank Credit Card XX9083 has been dispatched via BlueDart, '
        'AWB 12345678. Track at icicibank.com.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'JD-AIRTEL',
    '2026-10-12 10:00',
    'You have used 80% of your daily data. Dial *121# to check balance.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'VM-IRCTCI',
    '2026-10-12 10:00',
    'PNR 4521234567, Train 12627, Dt 05-11-26, SL S4 32. Fare Rs 655. Have '
        'a happy journey.',
    IgnoreReason.notABill,
  ),
  IgnoredCase(
    'AD-SWIGGY',
    '2026-10-12 10:00',
    'Your order of Rs 349 from Pizza Place will be delivered by 8:45 PM.',
    IgnoreReason.notABill,
  ),
];
