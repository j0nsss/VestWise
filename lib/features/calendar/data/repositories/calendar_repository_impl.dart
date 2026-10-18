import 'package:isar_community/isar.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/errors/result_guard.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._isar);

  final Isar _isar;

  IsarCollection<CalendarEventModel> get _events => _isar.calendarEventModels;

  @override
  Stream<List<CalendarEventModel>> watchAllEvents() =>
      _events.where().sortByStartDateTime().watch(fireImmediately: true);

  @override
  Stream<List<CalendarEventModel>> watchEventsForDay(DateTime day) {
    final DateTime start = DateTime(day.year, day.month, day.day);
    final DateTime end = start.add(const Duration(days: 1));
    return _events
        .where()
        .startDateTimeBetween(start, end)
        .sortByStartDateTime()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<CalendarEventModel>> watchUpcomingEvents({int limit = 3}) =>
      _events
          .where()
          .startDateTimeGreaterThan(DateTime.now())
          .sortByStartDateTime()
          .limit(limit)
          .watch(fireImmediately: true);

  @override
  Future<Result<CalendarEventModel>> getEventById(int id) =>
      resultGuard(() async {
        final CalendarEventModel? event = await _events.get(id);
        if (event == null) {
          throw StateError('Event $id not found');
        }
        return event;
      }, operation: 'getEventById');

  @override
  Future<Result<int>> createEvent(CalendarEventModel event) =>
      resultGuard(() async {
        await _isar.writeTxn(() async {
          event.id = await _events.put(event);
        });
        return event.id;
      }, operation: 'createEvent');

  @override
  Future<Result<void>> updateEvent(CalendarEventModel event) =>
      resultGuard(() async {
        await _isar.writeTxn(() => _events.put(event));
      }, operation: 'updateEvent');

  @override
  Future<Result<void>> deleteEvent(int id) => resultGuard(() async {
    await _isar.writeTxn(() => _events.delete(id));
  }, operation: 'deleteEvent');
}
