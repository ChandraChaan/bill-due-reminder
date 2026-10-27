import 'package:flutter/material.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import 'bill_icons.dart';

/// "Due in 3 days", "Due today", "2 days overdue" or "Paid 3 Nov".
String dueLabel(AppLocalizations l10n, TrackedBill bill, CalendarDate today) {
  if (bill.isPaid) {
    return bill.paidBy == PaidBy.sms
        ? l10n.paidFromSms
        : l10n.paidOn(
            formatDay(CalendarDate.fromDateTime(bill.paidAt!.toLocal()), today),
          );
  }
  final days = today.daysUntil(bill.dueDate);
  return switch (days) {
    0 => l10n.dueToday,
    1 => l10n.dueTomorrow,
    > 1 => l10n.dueInDays(days),
    _ => l10n.overdueByDays(-days),
  };
}

class BillTile extends StatelessWidget {
  const BillTile({
    super.key,
    required this.bill,
    required this.today,
    required this.onTap,
  });

  final TrackedBill bill;
  final CalendarDate today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final days = today.daysUntil(bill.dueDate);
    final urgent = !bill.isPaid && days <= 1;
    final subtitle = [
      kindLabel(l10n, bill.kind),
      if (bill.accountRef != null) l10n.accountEnding(bill.accountRef!),
      formatDay(bill.dueDate, today),
    ].join(' · ');
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: bill.isPaid
            ? scheme.surfaceContainerHighest
            : scheme.secondaryContainer,
        foregroundColor: bill.isPaid
            ? scheme.onSurfaceVariant
            : scheme.onSecondaryContainer,
        child: Icon(billIcon(bill.kind)),
      ),
      title: Text(bill.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(
            children: [
              if (urgent) ...[
                Icon(Icons.schedule, size: 14, color: scheme.error),
                const SizedBox(width: 4),
              ] else if (bill.isPaid) ...[
                Icon(Icons.check_circle, size: 14, color: scheme.primary),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  dueLabel(l10n, bill, today),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: urgent ? scheme.error : scheme.onSurfaceVariant,
                    fontWeight: urgent ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: Text(
          bill.amountDue == null ? '—' : formatRupees(bill.amountDue!),
          textAlign: TextAlign.end,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: bill.isPaid ? TextDecoration.lineThrough : null,
            color: bill.isPaid ? scheme.onSurfaceVariant : null,
          ),
        ),
      ),
    );
  }
}
