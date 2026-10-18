import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestwise/core/notifications/notification_service.dart';

/// Exposes the single [NotificationService] to features.
///
/// `main.dart` calls `NotificationService.init()` before `runApp`.
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) => NotificationService());

/// Whether the user has been asked for notification permission and then turned
/// reminders off, so the Tasks/Calendar screens can show an inline banner
/// (P4-T2). Stays `false` until the permission dialog has actually been shown,
/// so it never nags a first-run user who simply hasn't set a reminder yet.
///
/// Invalidate after returning from system settings to re-check the OS state.
final FutureProvider<bool> notificationsBlockedProvider =
    FutureProvider<bool>((Ref ref) async {
  final NotificationService service = ref.watch(notificationServiceProvider);
  if (!await service.hasRequestedPermissions()) {
    return false;
  }
  return !await service.notificationsEnabled();
});

/// Everything the Settings screen needs to report about reminders (P5-T4).
class NotificationStatus {
  const NotificationStatus({
    required this.permissionRequested,
    required this.enabled,
    required this.exactAlarmsAllowed,
  });

  /// Whether the OS permission dialog has ever been shown.
  final bool permissionRequested;

  /// Whether notifications can currently reach the user.
  final bool enabled;

  /// Whether the OS still grants exact (to-the-minute) alarms.
  final bool exactAlarmsAllowed;
}

/// Live notification permission snapshot. Invalidate after returning from
/// system settings, or after asking for permission, to re-read the OS state.
final FutureProvider<NotificationStatus> notificationStatusProvider =
    FutureProvider<NotificationStatus>((Ref ref) async {
  final NotificationService service = ref.watch(notificationServiceProvider);
  return NotificationStatus(
    permissionRequested: await service.hasRequestedPermissions(),
    enabled: await service.notificationsEnabled(),
    exactAlarmsAllowed: await service.canScheduleExactNotifications(),
  );
});
