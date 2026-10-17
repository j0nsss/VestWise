import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:vestwise/features/calendar/domain/repositories/calendar_repository.dart';

part 'calendar_providers.g.dart';

@riverpod
CalendarRepository calendarRepository(Ref ref) {
  return CalendarRepositoryImpl(ref.watch(isarProvider).requireValue);
}

@riverpod
Stream<List<CalendarEventModel>> watchAllEvents(Ref ref) =>
    ref.watch(calendarRepositoryProvider).watchAllEvents();

@riverpod
Stream<List<CalendarEventModel>> watchEventsForDay(Ref ref, DateTime day) =>
    ref.watch(calendarRepositoryProvider).watchEventsForDay(day);

@riverpod
Stream<List<CalendarEventModel>> watchUpcomingEvents(Ref ref) =>
    ref.watch(calendarRepositoryProvider).watchUpcomingEvents();
