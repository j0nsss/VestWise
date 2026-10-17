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
