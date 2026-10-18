import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:vestwise/core/app_info.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/database/app_data_reset.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/storage/file_storage_service.dart';
import 'package:vestwise/core/theme/theme_provider.dart';
import 'package:vestwise/core/utils/byte_format.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_section_header.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';

/// Settings (plan P5-T4): theme mode, notification status, storage usage, app
/// version and a confirmed "Clear all data" reset.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const VWAppBar(title: AppStrings.settings),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const <Widget>[
          _Section(title: 'Appearance', child: _ThemeModeSelector()),
          SizedBox(height: AppSpacing.lg),
          _Section(title: 'Notifications', child: _NotificationSettings()),
          SizedBox(height: AppSpacing.lg),
          _Section(title: 'Storage', child: _StorageSettings()),
          SizedBox(height: AppSpacing.lg),
          _Section(title: 'About', child: _AboutSettings()),
          SizedBox(height: AppSpacing.lg),
          _DangerZone(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWSectionHeader(title: title),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends ConsumerWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text('System')),
        ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text('Light')),
        ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text('Dark')),
      ],
      selected: <ThemeMode>{mode},
      onSelectionChanged: (Set<ThemeMode> selection) => unawaited(
        ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
      ),
    );
  }
}

class _NotificationSettings extends ConsumerStatefulWidget {
  const _NotificationSettings();

  @override
  ConsumerState<_NotificationSettings> createState() =>
      _NotificationSettingsState();
}

class _NotificationSettingsState extends ConsumerState<_NotificationSettings>
    with WidgetsBindingObserver {
  bool _requesting = false;

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
    // The user may have changed permissions in system settings.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationStatusProvider);
      ref.invalidate(notificationsBlockedProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NotificationStatus> statusAsync =
        ref.watch(notificationStatusProvider);

    return statusAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: VWLoadingIndicator(),
      ),
      error: (Object error, StackTrace stack) => const Text(
        'Could not read the notification permission state.',
      ),
      data: (NotificationStatus status) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatusRow(
            label: 'Permission',
            value: _permissionLabel(status),
          ),
          _StatusRow(
            label: 'Exact alarms',
            value: status.exactAlarmsAllowed ? 'Allowed' : 'Approximate only',
          ),
          const SizedBox(height: AppSpacing.md),
          if (!status.permissionRequested)
            VWButton(
              label: 'Allow reminders',
              expand: true,
              isLoading: _requesting,
              onPressed: _requestPermission,
            )
          else if (!status.enabled)
            VWButton(
              label: 'Open notification settings',
              variant: VWButtonVariant.secondary,
              expand: true,
              onPressed: _openSettings,
            ),
        ],
      ),
    );
  }

  String _permissionLabel(NotificationStatus status) {
    if (status.enabled) {
      return 'Allowed';
    }
    return status.permissionRequested ? 'Not allowed' : 'Not requested yet';
  }

  Future<void> _requestPermission() async {
    setState(() => _requesting = true);
    try {
      await ref.read(notificationServiceProvider).requestPermissions();
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
        ref.invalidate(notificationStatusProvider);
        ref.invalidate(notificationsBlockedProvider);
      }
    }
  }

  void _openSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageSettings extends ConsumerWidget {
  const _StorageSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? bytes = ref.watch(importedFilesSizeProvider).value;
    final int fileCount =
        ref.watch(watchImportedDocumentsProvider).value?.length ?? 0;
    final String files = fileCount == 1 ? 'file' : 'files';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StatusRow(
          label: 'Imported files',
          value: '$fileCount $files',
        ),
        _StatusRow(
          label: 'Used',
          value: bytes == null ? '…' : formatBytes(bytes),
        ),
      ],
    );
  }
}

class _AboutSettings extends ConsumerWidget {
  const _AboutSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String version = ref.watch(appVersionProvider).value ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _StatusRow(label: 'App', value: AppStrings.appName),
        _StatusRow(label: 'Version', value: version),
      ],
    );
  }
}

/// Destructive reset behind a confirmation dialog (plan P5-T4).
class _DangerZone extends ConsumerStatefulWidget {
  const _DangerZone();

  @override
  ConsumerState<_DangerZone> createState() => _DangerZoneState();
}

class _DangerZoneState extends ConsumerState<_DangerZone> {
  bool _clearing = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VWSectionHeader(title: 'Danger zone'),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: const Text('Clear all data'),
            subtitle: const Text(
              'Removes every task, note, transaction, event and imported file '
              'from this device.',
            ),
            onTap: _clearing ? null : _confirm,
          ),
          if (_clearing) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            const VWLoadingIndicator(message: 'Clearing your data'),
          ],
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This permanently deletes all your VestWise data on this device. '
          'It cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear all data'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _clearing = true);
    try {
      final Isar isar = ref.read(isarProvider).requireValue;
      await resetAllData(
        isar: isar,
        storage: ref.read(fileStorageServiceProvider),
        notifications: ref.read(notificationServiceProvider),
      );
      ref
        ..invalidate(importedFilesSizeProvider)
        ..invalidate(notificationStatusProvider)
        ..invalidate(notificationsBlockedProvider)
        ..invalidate(balanceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local data cleared.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not clear data: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _clearing = false);
      }
    }
  }
}
