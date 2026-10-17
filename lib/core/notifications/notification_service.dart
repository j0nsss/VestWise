import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps `flutter_local_notifications` for scheduling task and calendar
/// reminders (plan P1-T4). Reminder ids are returned so they can be persisted
/// on [TaskModel] / [CalendarEventModel] and cancelled on edit/delete.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'vestwise_reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription = 'Task and calendar reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Initializes the plugin and sets the local timezone. Safe to call twice.
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    await _configureLocalTimeZone();

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      // Permissions are requested explicitly via [requestPermissions] at a
      // sensible moment (P4-T2), not on cold launch.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );

    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Requests notification permission on Android 13+ and iOS.
  /// Returns `true` when the app is allowed to post notifications.
  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? androidGranted = await android?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final bool? iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // On the inactive platform the call is skipped and returns null.
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  /// Schedules a one-shot notification and returns the id used (so it can be
  /// stored for later cancellation). Pass [id] to reuse an existing id.
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int? id,
  }) async {
    final int notificationId = id ?? _nextId();
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    return notificationId;
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();

  int _nextId() => DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
}
