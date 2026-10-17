import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestwise/core/notifications/notification_service.dart';

/// Exposes the single [NotificationService] to features.
///
/// `main.dart` calls `NotificationService.init()` before `runApp`.
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) => NotificationService());
