import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';

/// Inline banner shown on the Tasks and Calendar screens when the user has
/// turned reminders off system-wide (P4-T2).
///
/// Passive by design: it never re-prompts for permission, it only explains the
/// state and offers a link to system settings. It re-checks the OS state on app
/// resume so it disappears when the user re-enables notifications.
class VWNotificationBanner extends ConsumerStatefulWidget {
  const VWNotificationBanner({super.key});

  @override
  ConsumerState<VWNotificationBanner> createState() =>
      _VWNotificationBannerState();
}

class _VWNotificationBannerState extends ConsumerState<VWNotificationBanner>
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
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationsBlockedProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool show =
        ref.watch(notificationsBlockedProvider).value ?? false;
    if (!show) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Material(
        color: scheme.errorContainer,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.notifications_off_outlined,
                color: scheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Reminders are turned off, so due dates won’t notify you.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onErrorContainer),
                ),
              ),
              TextButton(
                onPressed: () => AppSettings.openAppSettings(
                  type: AppSettingsType.notification,
                ),
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
