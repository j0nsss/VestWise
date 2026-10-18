import 'package:isar_community/isar.dart';

part 'calendar_event_model.g.dart';

enum EventRepeat { none, daily, weekly, monthly, yearly }

@collection
class CalendarEventModel {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  @Index()
  late DateTime startDateTime;

  DateTime? endDateTime;

  bool isAllDay = false;

  @enumerated
  late EventRepeat repeat;

  bool hasReminder = false;

  int? reminderMinutesBefore;

  /// id returned by flutter_local_notifications; null if hasReminder is false.
  int? notificationId;

  /// Optional link to a TaskModel.id if this event represents a task deadline
  /// surfaced on the calendar, rather than a standalone event.
  int? linkedTaskId;

  int colorValue = 0xFF4F46E5;
}
