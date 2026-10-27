import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_data.dart';
import 'bill_sheet.dart';
import 'bill_tile.dart';
import 'onboarding_view.dart';
import 'providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The background SMS handler may have added bills while we were away.
    if (state == AppLifecycleState.resumed) {
      ref.read(appDataProvider.notifier).reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(appDataProvider);
    final showOnboarding = data.value?.onboarded == false;
    return Scaffold(
      appBar: AppBar(
        title: Text(showOnboarding ? l10n.appTitle : l10n.homeTitle),
        actions: [
          if (!showOnboarding)
            IconButton(
              tooltip: l10n.settingsTooltip,
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.go('/settings'),
            ),
        ],
      ),
      floatingActionButton: data.value == null || showOnboarding
          ? null
          : FloatingActionButton.extended(
              tooltip: l10n.addBillTooltip,
              onPressed: () => context.go('/add'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addBill),
            ),
      body: switch (data) {
        AsyncData(:final value) when !value.onboarded => const OnboardingView(),
        AsyncData(:final value) => _BillList(data: value),
        AsyncError() => _LoadError(
          onRetry: () => ref.invalidate(appDataProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.loadError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _BillList extends ConsumerWidget {
  const _BillList({required this.data});

  final AppData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = CalendarDate.fromDateTime(ref.watch(clockProvider)());
    final upcoming = data.book.upcoming;
    final overdue = [
      for (final b in upcoming)
        if (b.dueDate.isBefore(today)) b,
    ];
    final comingUp = [
      for (final b in upcoming)
        if (!b.dueDate.isBefore(today)) b,
    ];
    final paid = data.book.paid.take(20).toList();

    if (data.book.bills.isEmpty) {
      return _EmptyState(readSms: data.readSms);
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _MonthSummary(book: data.book, today: today),
          ),
        ),
        ..._section(context, l10n.sectionOverdue, overdue, today),
        ..._section(context, l10n.sectionUpcoming, comingUp, today),
        ..._section(context, l10n.sectionPaid, paid, today),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  List<Widget> _section(
    BuildContext context,
    String title,
    List<TrackedBill> bills,
    CalendarDate today,
  ) {
    if (bills.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
      SliverList.builder(
        itemCount: bills.length,
        itemBuilder: (context, i) => BillTile(
          key: ValueKey(bills[i].id),
          bill: bills[i],
          today: today,
          onTap: () => showBillSheet(context, bills[i].id),
        ),
      ),
    ];
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.book, required this.today});

  final BillBook book;
  final CalendarDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unpaid = book.totalDueIn(today.year, today.month, paid: false);
    final paid = book.totalDueIn(today.year, today.month, paid: true);
    final left = book.upcoming
        .where(
          (b) => b.dueDate.year == today.year && b.dueDate.month == today.month,
        )
        .length;
    final overdue = book.upcoming.where((b) => b.dueDate.isBefore(today));
    final overdueAmount = overdue.fold(0, (s, b) => s + (b.amountDue ?? 0));
    return Card.filled(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthSummaryTitle(formatMonth(today.year, today.month)),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupees(unpaid),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                l10n.monthSummaryCount(left),
                if (paid > 0) l10n.monthSummaryPaid(formatRupees(paid)),
              ].join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.overdueSummary(
                        overdue.length,
                        formatRupees(overdueAmount),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.readSms});

  final bool readSms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l10n.emptyTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              readSms ? l10n.emptyBodySms : l10n.emptyBodyManual,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (readSms) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.read(appDataProvider.notifier).rescan(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.emptyScan),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
