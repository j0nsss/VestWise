import 'package:vestwise/core/notifications/notification_service.dart';

/// A [NotificationService] that records instead of talking to the platform.
///
/// Only the calls a test asserts on are overridden; anything else would have
/// hit the notification plugin and failed, which is the signal that a test is
/// exercising a path it did not mean to.
class NotificationServiceSpy extends NotificationService {
  final List<int> cancelled = <int>[];

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}
