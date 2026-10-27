import 'package:sms_bill_parser/sms_bill_parser.dart';

import 'app_data.dart';

/// What reading a batch of SMS changed.
final class IngestResult {
  const IngestResult(this.data, this.newBills);
  final AppData data;

  /// Bills that didn't exist before this batch.
  final List<TrackedBill> newBills;
}

/// Reads [messages] (any order) into [data]: parses each one not seen before,
/// merges repeated reminders, and remembers a hash of every message so it is
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
  var book = data.book;
  for (final sms in sorted) {
    final hash = messageHash(sms);
    if (!seen.add(hash)) continue;
    processed.add(hash);
    final parsed = parser.parse(sms);
    if (parsed is BillNotice) book = book.addNotice(parsed);
  }
  final trimmed = processed.length > AppData.maxProcessed
      ? processed.sublist(processed.length - AppData.maxProcessed)
      : processed;
  return IngestResult(data.copyWith(book: book, processed: trimmed), [
    for (final b in book.bills)
      if (!before.contains(b.id)) b,
  ]);
}

/// Identifies a message without keeping its text.
String messageHash(SmsInput sms) => fnv1a64Hex('${sms.sender}\n${sms.body}');
