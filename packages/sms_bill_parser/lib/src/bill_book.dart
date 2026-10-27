import 'models.dart';

/// Where a tracked bill came from.
enum BillSource { sms, manual }

/// How a bill was marked as paid.
enum PaidBy { manual, sms }

/// A bill the app keeps track of: built from one or more [BillNotice]s or
/// typed in by the user. Holds only the extracted fields, never SMS text.
final class TrackedBill {
  const TrackedBill({
    required this.id,
    required this.kind,
    required this.issuerId,
    required this.name,
    required this.dueDate,
    required this.source,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.accountRef,
    this.amountDue,
    this.minimumDue,
    this.paidAt,
    this.paidBy,
    this.repeatMonthly = false,
    this.noticeCount = 1,
  });

  factory TrackedBill.fromNotice(BillNotice notice) => TrackedBill(
    id: billIdFor(notice),
    kind: notice.kind,
    issuerId: notice.issuer.id,
    name: notice.issuer.name,
    accountRef: notice.accountRef,
    amountDue: notice.amountDue,
    minimumDue: notice.minimumDue,
    dueDate: notice.dueDate,
    source: BillSource.sms,
    firstSeenAt: notice.receivedAt.toUtc(),
    lastSeenAt: notice.receivedAt.toUtc(),
  );

  factory TrackedBill.fromJson(Map<String, Object?> json) => TrackedBill(
    id: json['id']! as String,
    kind: BillKind.values.byName(json['kind']! as String),
    issuerId: json['issuerId']! as String,
    name: json['name']! as String,
    accountRef: json['accountRef'] as String?,
    amountDue: json['amountDue'] as int?,
    minimumDue: json['minimumDue'] as int?,
    dueDate: CalendarDate.parse(json['dueDate']! as String),
    source: BillSource.values.byName(json['source']! as String),
    firstSeenAt: DateTime.parse(json['firstSeenAt']! as String),
    lastSeenAt: DateTime.parse(json['lastSeenAt']! as String),
    paidAt: json['paidAt'] == null
        ? null
        : DateTime.parse(json['paidAt']! as String),
    paidBy: json['paidBy'] == null
        ? null
        : PaidBy.values.byName(json['paidBy']! as String),
    repeatMonthly: json['repeatMonthly'] as bool? ?? false,
    noticeCount: json['noticeCount'] as int? ?? 1,
  );

  final String id;
  final BillKind kind;

  /// Matching key of the company (`hdfc`, `airtel`); `manual` for typed-in
  /// bills.
  final String issuerId;

  /// What the user sees: issuer name, or the name typed in.
  final String name;

  /// Last digits of the card, loan, consumer or phone number.
  final String? accountRef;

  /// In paise.
  final int? amountDue;

  /// In paise.
  final int? minimumDue;

  final CalendarDate dueDate;
  final BillSource source;

  /// UTC time of the first and the latest SMS about this bill (or when it was
  /// typed in).
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;

  /// UTC time it was marked as paid; null while unpaid.
  final DateTime? paidAt;
  final PaidBy? paidBy;

  /// For typed-in bills: create next month's bill when this one is paid.
  final bool repeatMonthly;

  /// How many SMS were merged into this bill (statement plus reminders).
  final int noticeCount;

  bool get isPaid => paidAt != null;

  TrackedBill copyWith({
    BillKind? kind,
    String? name,
    String? accountRef,
    int? amountDue,
    int? minimumDue,
    CalendarDate? dueDate,
    DateTime? lastSeenAt,
    DateTime? paidAt,
    PaidBy? paidBy,
    bool clearPaid = false,
    bool clearAmount = false,
    bool? repeatMonthly,
    int? noticeCount,
  }) => TrackedBill(
    id: id,
    kind: kind ?? this.kind,
    issuerId: issuerId,
    name: name ?? this.name,
    accountRef: accountRef ?? this.accountRef,
    amountDue: clearAmount ? null : amountDue ?? this.amountDue,
    minimumDue: clearAmount ? null : minimumDue ?? this.minimumDue,
    dueDate: dueDate ?? this.dueDate,
    source: source,
    firstSeenAt: firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    paidAt: clearPaid ? null : paidAt ?? this.paidAt,
    paidBy: clearPaid ? null : paidBy ?? this.paidBy,
    repeatMonthly: repeatMonthly ?? this.repeatMonthly,
    noticeCount: noticeCount ?? this.noticeCount,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'issuerId': issuerId,
    'name': name,
    'accountRef': accountRef,
    'amountDue': amountDue,
    'minimumDue': minimumDue,
    'dueDate': dueDate.toString(),
    'source': source.name,
    'firstSeenAt': firstSeenAt.toIso8601String(),
    'lastSeenAt': lastSeenAt.toIso8601String(),
    'paidAt': paidAt?.toIso8601String(),
    'paidBy': paidBy?.name,
    'repeatMonthly': repeatMonthly,
    'noticeCount': noticeCount,
  };

  @override
  bool operator ==(Object other) =>
      other is TrackedBill &&
      other.id == id &&
      other.kind == kind &&
      other.issuerId == issuerId &&
      other.name == name &&
      other.accountRef == accountRef &&
      other.amountDue == amountDue &&
      other.minimumDue == minimumDue &&
      other.dueDate == dueDate &&
      other.source == source &&
      other.firstSeenAt == firstSeenAt &&
      other.lastSeenAt == lastSeenAt &&
      other.paidAt == paidAt &&
      other.paidBy == paidBy &&
      other.repeatMonthly == repeatMonthly &&
      other.noticeCount == noticeCount;

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    issuerId,
    name,
    accountRef,
    amountDue,
    minimumDue,
    dueDate,
    source,
    firstSeenAt,
    lastSeenAt,
    paidAt,
    paidBy,
    repeatMonthly,
    noticeCount,
  );

  @override
  String toString() =>
      'TrackedBill($id, ${kind.name}, $name, ref: $accountRef, '
      'due: $amountDue on $dueDate, paid: $paidAt)';
}

/// A stable id for the bill a notice belongs to.
String billIdFor(BillNotice notice) =>
    'sms-${fnv1a64Hex([notice.kind.name, notice.issuer.id, notice.accountRef ?? '', notice.dueDate.toString()].join('|'))}';

/// Two reminders belong to the same bill when the kind and the issuer match,
/// the account numbers don't contradict each other, and the due dates are at
/// most this many days apart.
const int sameBillToleranceDays = 2;

/// Whether two account refs can be the same account: equal, either unknown,
/// or one is the tail of the other (`10` and `4310`).
bool refsCompatible(String? a, String? b) {
  if (a == null || b == null) return true;
  return a.endsWith(b) || b.endsWith(a);
}

/// The user's bills, with the rules for merging repeated reminders.
///
/// Immutable: every change returns a new book.
final class BillBook {
  BillBook([Iterable<TrackedBill> bills = const []])
    : bills = List.unmodifiable(bills);

  final List<TrackedBill> bills;

  TrackedBill? byId(String id) {
    for (final bill in bills) {
      if (bill.id == id) return bill;
    }
    return null;
  }

  /// The existing bill [notice] repeats, if any.
  TrackedBill? findSameBill(BillNotice notice) {
    TrackedBill? best;
    var bestGap = sameBillToleranceDays + 1;
    for (final bill in bills) {
      if (bill.source != BillSource.sms ||
          bill.kind != notice.kind ||
          bill.issuerId != notice.issuer.id ||
          !refsCompatible(bill.accountRef, notice.accountRef)) {
        continue;
      }
      final gap = bill.dueDate.daysUntil(notice.dueDate).abs();
      if (gap < bestGap) {
        best = bill;
        bestGap = gap;
      }
    }
    return best;
  }

  /// Adds [notice] as a new bill, or merges it into the bill it repeats:
  /// the newest message's amounts and due date win, a longer account ref
  /// wins, and a bill already marked paid stays paid.
  BillBook addNotice(BillNotice notice) {
    final existing = findSameBill(notice);
    if (existing == null) {
      return BillBook([...bills, TrackedBill.fromNotice(notice)]);
    }
    final receivedAt = notice.receivedAt.toUtc();
    final newer = !receivedAt.isBefore(existing.lastSeenAt);
    final ref =
        (notice.accountRef?.length ?? 0) > (existing.accountRef?.length ?? 0)
        ? notice.accountRef
        : existing.accountRef;
    final merged = existing.copyWith(
      accountRef: ref,
      amountDue: newer
          ? notice.amountDue
          : existing.amountDue ?? notice.amountDue,
      minimumDue: newer
          ? notice.minimumDue
          : existing.minimumDue ?? notice.minimumDue,
      dueDate: newer ? notice.dueDate : null,
      lastSeenAt: newer ? receivedAt : null,
      noticeCount: existing.noticeCount + 1,
    );
    return _replace(merged);
  }

  /// Adds or replaces a typed-in or edited bill.
  BillBook upsert(TrackedBill bill) =>
      byId(bill.id) == null ? BillBook([...bills, bill]) : _replace(bill);

  /// Marks a bill as paid. A typed-in monthly bill gets next month's copy.
  BillBook markPaid(String id, DateTime at, {PaidBy by = PaidBy.manual}) {
    final bill = byId(id);
    if (bill == null || bill.isPaid) return this;
    var book = _replace(bill.copyWith(paidAt: at.toUtc(), paidBy: by));
    if (bill.repeatMonthly) {
      final nextDue = bill.dueDate.addMonths(1);
      final nextId = '${bill.id.split('@').first}@$nextDue';
      if (book.byId(nextId) == null) {
        book = book.upsert(
          TrackedBill(
            id: nextId,
            kind: bill.kind,
            issuerId: bill.issuerId,
            name: bill.name,
            accountRef: bill.accountRef,
            amountDue: bill.amountDue,
            dueDate: nextDue,
            source: bill.source,
            firstSeenAt: at.toUtc(),
            lastSeenAt: at.toUtc(),
            repeatMonthly: true,
          ),
        );
      }
    }
    return book;
  }

  BillBook markUnpaid(String id) {
    final bill = byId(id);
    if (bill == null || !bill.isPaid) return this;
    return _replace(bill.copyWith(clearPaid: true));
  }

  BillBook remove(String id) => BillBook(bills.where((bill) => bill.id != id));

  /// Drops paid bills that were due more than [keepDays] before [today], so
  /// the history doesn't grow forever.
  BillBook prune(CalendarDate today, {int keepDays = 400}) => BillBook(
    bills.where(
      (bill) => !bill.isPaid || bill.dueDate.daysUntil(today) <= keepDays,
    ),
  );

  /// Unpaid bills, soonest (or most overdue) first.
  List<TrackedBill> get upcoming =>
      bills.where((bill) => !bill.isPaid).toList()..sort(_byDueDate);

  /// Paid bills, most recently due first.
  List<TrackedBill> get paid =>
      bills.where((bill) => bill.isPaid).toList()
        ..sort((a, b) => _byDueDate(b, a));

  /// Sum of amounts (paise) of bills due in [year]-[month].
  int totalDueIn(int year, int month, {bool? paid}) => bills
      .where(
        (bill) =>
            bill.dueDate.year == year &&
            bill.dueDate.month == month &&
            (paid == null || bill.isPaid == paid),
      )
      .fold(0, (sum, bill) => sum + (bill.amountDue ?? 0));

  BillBook _replace(TrackedBill bill) =>
      BillBook([for (final b in bills) b.id == bill.id ? bill : b]);

  static int _byDueDate(TrackedBill a, TrackedBill b) {
    final byDate = a.dueDate.compareTo(b.dueDate);
    return byDate != 0 ? byDate : a.name.compareTo(b.name);
  }
}

/// 64-bit FNV-1a hash of [text] as 16 hex characters. Used for bill ids and
/// to remember which messages were already read without keeping their text.
String fnv1a64Hex(String text) {
  // Two 32-bit halves so this works the same on the web and the VM.
  var hi = 0xcbf29ce4;
  var lo = 0x84222325;
  for (final unit in text.codeUnits) {
    lo ^= unit;
    // (hi:lo) × FNV prime 0x100000001b3, modulo 2^64.
    final loMul = lo * 0x1b3;
    hi = (hi * 0x1b3 + lo * 0x100 + loMul ~/ 0x100000000) & 0xffffffff;
    lo = loMul & 0xffffffff;
  }
  return hi.toRadixString(16).padLeft(8, '0') +
      lo.toRadixString(16).padLeft(8, '0');
}
