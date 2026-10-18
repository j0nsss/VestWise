import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The id a scheduled reminder was stored under, plus whether the OS will
/// deliver it at the exact requested time (P4-T1). Exact alarms can be revoked
/// by the user on Android 12+, so callers should surface [isExact] `false` as a
/// one-time "your reminder may be a little late" notice.
class ScheduledReminder {
  const ScheduledReminder({required this.id, required this.isExact});

  final int id;
  final bool isExact;
}

/// Wraps `flutter_local_notifications` for scheduling task and calendar
/// reminders (plan P1-T4). Reminder ids are returned so they can be persisted
/// on [TaskModel] / [CalendarEventModel] and cancelled on edit/delete.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'vestwise_reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription = 'Task and calendar reminders';

  /// Set once the user has been told that exact alarms are unavailable, so the
  /// notice is shown at most once (P4-T1).
  static const String _inexactNoticeKey = 'vw_inexact_alarm_notice_shown';

  /// Set the first time the OS permission dialog is shown, so the "reminders
  /// off" banner is never shown before the user has actually been asked
  /// (P4-T2).
  static const String _requestedKey = 'vw_notifications_requested';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  /// Initializes the plugin and sets the local timezone. Safe to call twice.
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    await _configureLocalTimeZone();

    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

  /// Requests notification permission on Android 13+ and iOS (P4-T2).
  /// Returns `true` when the app is allowed to post notifications.
  Future<bool> requestPermissions() async {
    final bool? androidGranted = await _android
        ?.requestNotificationsPermission();
    final bool? iosGranted = await _ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_requestedKey, true);

    // On the inactive platform the call is skipped and returns null.
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  /// Whether the OS permission dialog has ever been shown (P4-T2). Used to
  /// avoid showing the "reminders off" banner before the user was ever asked.
  Future<bool> hasRequestedPermissions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_requestedKey) ?? false;
  }

  /// Whether notifications can currently reach the user, re-checked against the
  /// OS so a Settings change is reflected on the next screen visit (P4-T2).
  Future<bool> notificationsEnabled() async {
    final bool? androidEnabled = await _android?.areNotificationsEnabled();
    if (androidEnabled != null) {
      return androidEnabled;
    }

    final NotificationsEnabledOptions? iosOptions = await _ios
        ?.checkPermissions();
    if (iosOptions != null) {
      return iosOptions.isEnabled || iosOptions.isProvisionalEnabled;
    }

    return true;
  }

  /// Whether the OS currently allows exact alarms (P4-T1). `true` on platforms
  /// without the concept (e.g. Android < 12, iOS).
  Future<bool> canScheduleExactNotifications() async {
    final AndroidFlutterLocalNotificationsPlugin? android = _android;
    if (android == null) {
      return true;
    }
    return await android.canScheduleExactNotifications() ?? true;
  }

  /// Prompts for the exact-alarm permission when needed and reports whether
  /// exact scheduling is possible afterwards (P4-T1).
  Future<bool> _ensureExactAlarmCapability() async {
    if (await canScheduleExactNotifications()) {
      return true;
    }
    await _android?.requestExactAlarmsPermission();
    return canScheduleExactNotifications();
  }

  /// Schedules a one-shot reminder and returns the id used (so it can be stored
  /// for later cancellation) together with whether it will fire exactly.
  ///
  /// Degrades gracefully to inexact scheduling when the user has disabled exact
  /// alarms, rather than throwing (P4-T1). Pass [id] to reuse an existing id.
  Future<ScheduledReminder> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int? id,
  }) async {
    final int notificationId = id ?? _nextId();
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final bool isExact = await _ensureExactAlarmCapability();

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
      androidScheduleMode: isExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );

    return ScheduledReminder(id: notificationId, isExact: isExact);
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Whether the "exact alarms are off" notice still needs to be shown (P4-T1).
  Future<bool> shouldShowInexactAlarmNotice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_inexactNoticeKey) ?? false);
  }

  /// Records that the inexact-alarm notice has been shown, so it never repeats.
  Future<void> markInexactAlarmNoticeShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_inexactNoticeKey, true);
  }

  int _nextId() => DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
}
