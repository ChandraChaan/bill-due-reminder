/// Reads Indian bill and due-date SMS (credit cards, loans, utilities,
/// telecom, insurance) and keeps a de-duplicated list of bills.
///
/// Pure Dart: no Flutter, no I/O, no network.
library;

export 'src/bill_book.dart';
export 'src/models.dart';
export 'src/parser.dart';
export 'src/scan.dart' show findAccountRef, findAmounts, findDates;
export 'src/sender.dart' show businessSenderId, isBusinessSender;
