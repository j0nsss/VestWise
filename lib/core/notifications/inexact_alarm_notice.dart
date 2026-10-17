import 'package:flutter/material.dart';
import 'package:vestwise/core/notifications/notification_service.dart';

/// Shows a one-time SnackBar when a reminder had to be scheduled inexactly
/// because the user has disabled exact alarms (P4-T1). The root
/// [ScaffoldMessenger] keeps it visible across the route pop that follows a
/// save.
Future<void> maybeShowInexactAlarmNotice(
  BuildContext context,
  NotificationService service,
) async {
  if (!await service.shouldShowInexactAlarmNotice()) {
    return;
  }
  await service.markInexactAlarmNoticeShown();
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Exact alarms are off, so this reminder may arrive a few minutes '
        'late. Turn on "Alarms & reminders" in system settings for precision.',
      ),
      duration: Duration(seconds: 6),
    ),
  );
}
