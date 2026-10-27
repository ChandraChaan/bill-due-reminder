import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import 'providers.dart';

/// Adds a bill by hand, or edits any bill.
class BillFormScreen extends ConsumerWidget {
  const BillFormScreen({super.key, this.billId});

  final String? billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appDataProvider);
    return switch (data) {
      AsyncData(:final value) => _BillForm(
        existing: billId == null ? null : value.book.byId(billId!),
      ),
      AsyncError() => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(appDataProvider),
            child: Text(AppLocalizations.of(context).retry),
          ),
        ),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _BillForm extends ConsumerStatefulWidget {
  const _BillForm({required this.existing});

  final TrackedBill? existing;

  @override
  ConsumerState<_BillForm> createState() => _BillFormState();
}

class _BillFormState extends ConsumerState<_BillForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  late final TrackedBill? _existing = widget.existing;
  BillKind _kind = BillKind.other;
  late CalendarDate _due;
  bool _repeat = false;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    final bill = _existing;
    _due = bill?.dueDate ?? CalendarDate.fromDateTime(now).addDays(7);
    if (bill != null) {
      _name.text = bill.name;
      _amount.text = bill.amountDue == null
          ? ''
          : editableRupees(bill.amountDue!);
      _kind = bill.kind;
      _repeat = bill.repeatMonthly;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = ref.read(clockProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due.toLocalDateTime(),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() => _due = CalendarDate.fromDateTime(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = ref.read(clockProvider)().toUtc();
    final amount = parseRupees(_amount.text);
    final existing = _existing;
    final bill = existing == null
        ? TrackedBill(
            id: 'm-${now.microsecondsSinceEpoch}',
            kind: _kind,
            issuerId: 'manual',
            name: _name.text.trim(),
            amountDue: amount,
            dueDate: _due,
            source: BillSource.manual,
            firstSeenAt: now,
            lastSeenAt: now,
            repeatMonthly: _repeat,
          )
        : existing.copyWith(
            kind: _kind,
            name: _name.text.trim(),
            amountDue: amount,
            clearAmount: amount == null,
            dueDate: _due,
            repeatMonthly: _repeat,
          );
    await ref.read(appDataProvider.notifier).save(bill);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = CalendarDate.fromDateTime(ref.watch(clockProvider)());
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l10n.formTitleAdd : l10n.formTitleEdit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.formName,
                hintText: l10n.formNameHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.formNameRequired
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BillKind>(
              initialValue: _kind,
              decoration: InputDecoration(labelText: l10n.formKind),
              items: [
                for (final kind in BillKind.values)
                  DropdownMenuItem(
                    value: kind,
                    child: Text(kindLabel(l10n, kind)),
                  ),
              ],
              onChanged: (kind) => setState(() => _kind = kind ?? _kind),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.formAmount),
              validator: (v) =>
                  (v != null && v.trim().isNotEmpty && parseRupees(v) == null)
                  ? l10n.formAmountInvalid
                  : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.formDueDate),
              subtitle: Text(formatDay(_due, today)),
              onTap: _pickDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _repeat,
              onChanged: (v) => setState(() => _repeat = v),
              title: Text(l10n.formRepeat),
              subtitle: Text(l10n.formRepeatHelp),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l10n.formSave)),
          ],
        ),
      ),
    );
  }
}
