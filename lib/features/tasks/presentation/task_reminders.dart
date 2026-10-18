import 'package:vestwise/core/notifications/notification_service.dart';

/// Cancels a task's pending reminder, swallowing any failure.
///
/// Cancellation is best-effort everywhere it happens (plan P4-T3): the reminder
/// may already have fired, or the device may have no notification channel, and
/// neither is a good reason to turn completing or deleting a task into an error.
///
/// One implementation, called by the detail screen's save/delete paths, the
/// list's completion path and the list's swipe-to-delete (P10-TASKS-3) — the
/// alternative was three copies of the same try/catch drifting apart.
Future<void> cancelTaskReminder(
  NotificationService notifications,
  int? notificationId,
) async {
  if (notificationId == null) {
    return;
  }
  try {
    await notifications.cancelNotification(notificationId);
  } catch (_) {
    // Already fired, or unavailable.
  }
}
