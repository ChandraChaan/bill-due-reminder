import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/repositories.dart';
import 'providers.dart';

/// First run: explains exactly what is read and kept, before Android's SMS
/// permission dialog appears. Choosing manual entry is a first-class option.
class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  bool _busy = false;

  Future<void> _choose({required bool sms}) async {
    setState(() => _busy = true);
    final controller = ref.read(appDataProvider.notifier);
    // Reminders need notifications; ask once, right after the user's choice.
    await ref.read(reminderSchedulerProvider).requestPermission();
    if (sms) {
      final access = await controller.enableSms();
      if (!mounted) return;
      if (access != SmsAccess.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).onboardingDeniedNote),
          ),
        );
      }
    } else {
      await controller.finishOnboarding();
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Icon(
            Icons.notifications_active_outlined,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingTitle,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingBody,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _Point(
            icon: Icons.sms_outlined,
            title: l10n.onboardingReadsTitle,
            body: l10n.onboardingReads,
          ),
          _Point(
            icon: Icons.inventory_2_outlined,
            title: l10n.onboardingKeepsTitle,
            body: l10n.onboardingKeeps,
          ),
          _Point(
            icon: Icons.wifi_off_outlined,
            title: l10n.onboardingNetTitle,
            body: l10n.onboardingNet,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : () => _choose(sms: true),
            child: Text(l10n.onboardingAllow),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : () => _choose(sms: false),
            child: Text(l10n.onboardingManual),
          ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
