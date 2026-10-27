import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import 'bill_icons.dart';
import 'bill_tile.dart';
import 'providers.dart';

Future<void> showBillSheet(BuildContext context, String billId) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BillSheet(billId: billId),
    );

class BillSheet extends ConsumerWidget {
  const BillSheet({super.key, required this.billId});

  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bill = ref.watch(
      appDataProvider.select((d) => d.value?.book.byId(billId)),
    );
    if (bill == null) return const SizedBox.shrink();
    final today = CalendarDate.fromDateTime(ref.watch(clockProvider)());
    final controller = ref.read(appDataProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(billIcon(bill.kind), color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(bill.name, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                kindLabel(l10n, bill.kind),
                if (bill.accountRef != null)
                  l10n.accountEnding(bill.accountRef!),
              ].join(' · '),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              bill.amountDue == null
                  ? l10n.amountUnknown
                  : formatRupees(bill.amountDue!),
              style: theme.textTheme.headlineMedium,
            ),
            if (bill.minimumDue != null)
              Text(l10n.minimumDue(formatRupees(bill.minimumDue!))),
            const SizedBox(height: 8),
            Text(
              '${l10n.dueOn(formatDay(bill.dueDate, today))} · '
              '${dueLabel(l10n, bill, today)}',
            ),
            const SizedBox(height: 4),
            Text(
              [
                bill.source == BillSource.sms
                    ? l10n.billSourceSms(bill.noticeCount)
                    : l10n.billSourceManual,
                if (bill.repeatMonthly) l10n.billRepeats,
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: bill.isPaid
                  ? OutlinedButton.icon(
                      onPressed: () {
                        controller.markUnpaid(bill.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.undo),
                      label: Text(l10n.billMarkUnpaid),
                    )
                  : FilledButton.icon(
                      onPressed: () {
                        controller.markPaid(bill.id);
                        Navigator.pop(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.billMarkedPaid),
                            action: SnackBarAction(
                              label: l10n.undo,
                              onPressed: () => controller.markUnpaid(bill.id),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: Text(l10n.billMarkPaid),
                    ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/edit/${bill.id}');
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.billEdit),
                ),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final removed = await controller.delete(bill.id);
                    if (removed == null) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.billDeleted),
                        action: SnackBarAction(
                          label: l10n.undo,
                          onPressed: () => controller.save(removed),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.billDelete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
