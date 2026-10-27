import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/app_data.dart';
import '../domain/repositories.dart';
import 'providers.dart';

/// The app version shown in Settings; kept in step with pubspec.yaml.
const String appVersion = '1.0.0';

final _smsAccessProvider = FutureProvider.autoDispose<SmsAccess>(
  (ref) => ref.watch(smsSourceProvider).access(),
);
final _notificationsProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(reminderSchedulerProvider).notificationsAllowed(),
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(appDataProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: switch (data) {
        AsyncData(:final value) => _SettingsList(data: value),
        AsyncError() => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(appDataProvider),
            child: Text(l10n.retry),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList({required this.data});

  final AppData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(appDataProvider.notifier);
    final access = ref.watch(_smsAccessProvider).value;
    final notificationsOn = ref.watch(_notificationsProvider).value ?? true;
    final settings = data.settings;
    final smsOn = data.readSms && access == SmsAccess.granted;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _Header(l10n.settingsSmsSection),
        ListTile(
          leading: Icon(smsOn ? Icons.sms_outlined : Icons.edit_note),
          title: Text(smsOn ? l10n.settingsSmsOn : l10n.settingsSmsOff),
          subtitle: access == SmsAccess.blocked
              ? Text(l10n.settingsSmsDeniedForever)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (smsOn) ...[
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final found = await controller.rescan();
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.settingsScanResult(found))),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.settingsScanNow),
                ),
                OutlinedButton(
                  onPressed: controller.disableSms,
                  child: Text(l10n.settingsSmsTurnOff),
                ),
              ] else if (access == SmsAccess.blocked)
                FilledButton.tonal(
                  onPressed: () async {
                    await ref.read(smsSourceProvider).openAppSettings();
                    ref.invalidate(_smsAccessProvider);
                  },
                  child: Text(l10n.settingsOpenAndroid),
                )
              else
                FilledButton.tonal(
                  onPressed: () async {
                    await controller.enableSms();
                    ref.invalidate(_smsAccessProvider);
                  },
                  child: Text(l10n.settingsSmsTurnOn),
                ),
            ],
          ),
        ),
        _Header(l10n.settingsRemindersSection),
        if (!notificationsOn)
          ListTile(
            leading: Icon(
              Icons.notifications_off_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(l10n.settingsNotificationsOff),
            trailing: TextButton(
              onPressed: () async {
                await ref.read(reminderSchedulerProvider).requestPermission();
                ref.invalidate(_notificationsProvider);
              },
              child: Text(l10n.settingsNotificationsAllow),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            l10n.settingsRemindBefore,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final days in ReminderSettings.choices)
                FilterChip(
                  label: Text(l10n.settingsDaysBefore(days)),
                  selected: settings.daysBefore.contains(days),
                  onSelected: (on) => controller.updateSettings(
                    settings.copyWith(
                      daysBefore: on
                          ? {...settings.daysBefore, days}
                          : ({...settings.daysBefore}..remove(days)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(l10n.settingsReminderTime),
          subtitle: Text(
            TimeOfDay(
              hour: settings.hour,
              minute: settings.minute,
            ).format(context),
          ),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: settings.hour,
                minute: settings.minute,
              ),
            );
            if (picked == null) return;
            await controller.updateSettings(
              settings.copyWith(hour: picked.hour, minute: picked.minute),
            );
          },
        ),
        _Header(l10n.settingsPrivacySection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.settingsPrivacyBody,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: Icon(
            Icons.delete_forever_outlined,
            color: theme.colorScheme.error,
          ),
          title: Text(
            l10n.settingsDeleteAll,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () => _confirmDeleteAll(context, ref),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            l10n.settingsAbout(appVersion),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsDeleteAllConfirmTitle),
        content: Text(l10n.settingsDeleteAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.settingsDeleteAllConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(appDataProvider.notifier).deleteAll();
    messenger.showSnackBar(SnackBar(content: Text(l10n.settingsDeleted)));
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );
}
