import 'package:sms_bill_parser/sms_bill_parser.dart';
import 'package:test/test.dart';

void main() {
  const received = CalendarDate(2026, 10, 27);

  group('findAmounts', () {
    final cases = {
      'Rs.1,23,456.00': 12345600,
      'Rs 5000/-': 500000,
      'INR 12,345.6': 1234560,
      'INR12345': 1234500,
      '₹ 999': 99900,
      '₹1,02,345.75': 10234575,
      'rs. 49.5': 4950,
      'Rs: 300': 30000,
      'USD 1,234.00 western grouping INR 1,234,567.89': 123456789,
    };
    cases.forEach((text, paise) {
      test(text, () => expect(findAmounts(text).last.paise, paise));
    });

    test('ignores words ending in rs', () {
      expect(findAmounts('Thanks for 24 hours 500 users'), isEmpty);
    });
  });

  group('findDates', () {
    final cases = {
      '05-Nov-26': '2026-11-05',
      '05-Nov-2026': '2026-11-05',
      '05/11/2026': '2026-11-05',
      '05/11/26': '2026-11-05',
      '5.11.2026': '2026-11-05',
      '2026-11-05': '2026-11-05',
      '5th Nov': '2026-11-05',
      '5th of November': '2026-11-05',
      '05 November 2026': '2026-11-05',
      '05NOV26': '2026-11-05',
      'Nov 5, 2026': '2026-11-05',
      'November 5th': '2026-11-05',
      'today': '2026-10-27',
      'tomorrow': '2026-10-28',
      'in 3 days': '2026-10-30',
    };
    cases.forEach((text, expected) {
      test(text, () {
        final dates = findDates('Due on $text.', received);
        expect(dates.map((d) => d.date.toString()), [expected]);
      });
    });

    test('a date without a year rolls over into next year', () {
      final dates = findDates('due 5th Jan', const CalendarDate(2026, 12, 20));
      expect(dates.single.date, const CalendarDate(2027, 1, 5));
    });

    test('a recent past date without a year stays in this year', () {
      final dates = findDates('was due 20th Oct', received);
      expect(dates.single.date, const CalendarDate(2026, 10, 20));
    });

    test('rejects impossible dates', () {
      expect(findDates('31/11/2026 and 30-Feb-26', received), isEmpty);
    });

    test('does not read amounts or times as dates', () {
      expect(findDates('Rs 1,234.56 at 10:30', received), isEmpty);
    });
  });

  group('findAccountRef', () {
    final cases = {
      'Credit Card ending 4417': '4417',
      'Card XX9083 statement': '9083',
      'Loan A/c No. XXXXXXX5521': '5521',
      'CA No. 60012345678': '5678',
      'K No 2391000123': '0123',
      'for 98XXXXXX21': '21',
      'number 9876543210': '3210',
      'BOBCARD ending 7720': '7720',
    };
    cases.forEach((text, ref) {
      test(text, () => expect(findAccountRef(text), ref));
    });

    test('null when there is no number', () {
      expect(findAccountRef('Your bill is due tomorrow'), isNull);
    });
  });

  group('businessSenderId', () {
    test('accepts Indian headers with and without the category suffix', () {
      expect(businessSenderId('VM-HDFCBK'), 'HDFCBK');
      expect(businessSenderId('JD-AIRTEL-S'), 'AIRTEL');
      expect(businessSenderId('AX-SBICRD-T'), 'SBICRD');
      expect(businessSenderId('vk-bescom'), 'BESCOM');
      expect(businessSenderId('HDFCBK'), 'HDFCBK');
    });

    test('rejects phone numbers, names and promotional headers', () {
      expect(businessSenderId('+919876543210'), isNull);
      expect(businessSenderId('9876543210'), isNull);
      expect(businessSenderId('Mom'), isNull);
      expect(businessSenderId('Rahul Sharma'), isNull);
      expect(businessSenderId('VM-HDFCBK-P'), isNull);
      expect(businessSenderId(''), isNull);
    });
  });

  group('CalendarDate', () {
    test('addMonths clamps to the end of the month', () {
      expect(
        const CalendarDate(2026, 1, 31).addMonths(1),
        const CalendarDate(2026, 2, 28),
      );
      expect(
        const CalendarDate(2026, 12, 15).addMonths(1),
        const CalendarDate(2027, 1, 15),
      );
    });

    test('daysUntil and parse round trip', () {
      const a = CalendarDate(2026, 10, 27);
      expect(a.daysUntil(CalendarDate.parse('2026-11-04')), 8);
      expect(CalendarDate.parse(a.toString()), a);
    });
  });

  test('fnv1a64Hex matches the reference values', () {
    expect(fnv1a64Hex(''), 'cbf29ce484222325');
    expect(fnv1a64Hex('a'), 'af63dc4c8601ec8c');
    expect(fnv1a64Hex('foobar'), '85944171f73967e8');
  });
}
