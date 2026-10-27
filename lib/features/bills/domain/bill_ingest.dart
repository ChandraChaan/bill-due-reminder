import 'package:sms_bill_parser/sms_bill_parser.dart';

import 'app_data.dart';

/// What reading a batch of SMS changed.
final class IngestResult {
  const IngestResult(this.data, this.newBills, [this.paidBills = const []]);
  final AppData data;

  /// Bills that didn't exist before this batch.
  final List<TrackedBill> newBills;

  /// Bills this batch marked as paid from a payment SMS.
  final List<TrackedBill> paidBills;
}

/// Reads [messages] (any order) into [data]: parses each one not seen before,
/// merges repeated reminders, marks bills paid when a matching payment SMS
/// comes in, and remembers a hash of every message so it is
/// never read twice. Message text is not kept.
IngestResult ingestMessages(
  AppData data,
  Iterable<SmsInput> messages, {
  BillSmsParser parser = const BillSmsParser(),
}) {
  final sorted = messages.toList()
    ..sort((a, b) => a.receivedAt.compareTo(b.receivedAt));
  final seen = data.processed.toSet();
  final processed = [...data.processed];
  final before = {for (final b in data.book.bills) b.id};
  final unpaidBefore = {
    for (final b in data.book.bills)
      if (!b.isPaid) b.id,
  };
  var book = data.book;
  for (final sms in sorted) {
    final hash = messageHash(sms);
    if (!seen.add(hash)) continue;
    processed.add(hash);
    final parsed = parser.parse(sms);
    book = switch (parsed) {
      BillNotice() => book.addNotice(parsed),
      PaymentNotice() => book.applyPayment(parsed),
      IgnoredSms() => book,
    };
  }
  final trimmed = processed.length > AppData.maxProcessed
      ? processed.sublist(processed.length - AppData.maxProcessed)
      : processed;
  return IngestResult(
    data.copyWith(book: book, processed: trimmed),
    [
      for (final b in book.bills)
        if (!before.contains(b.id)) b,
    ],
    [
      for (final b in book.bills)
        if (b.paidBy == PaidBy.sms &&
            (unpaidBefore.contains(b.id) || !before.contains(b.id)))
          b,
    ],
  );
}

/// Identifies a message without keeping its text.
String messageHash(SmsInput sms) => fnv1a64Hex('${sms.sender}\n${sms.body}');
