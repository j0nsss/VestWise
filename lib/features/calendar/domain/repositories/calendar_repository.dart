import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';

/// Data-access boundary for calendar events (plan P2-T2).
abstract interface class CalendarRepository {
  Stream<List<CalendarEventModel>> watchAllEvents();

  Stream<List<CalendarEventModel>> watchEventsForDay(DateTime day);

  Stream<List<CalendarEventModel>> watchUpcomingEvents({int limit = 3});

  Future<Result<CalendarEventModel>> getEventById(int id);

  Future<Result<int>> createEvent(CalendarEventModel event);

  Future<Result<void>> updateEvent(CalendarEventModel event);

  Future<Result<void>> deleteEvent(int id);
}
