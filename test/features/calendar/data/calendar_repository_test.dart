import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:vestwise/features/calendar/domain/repositories/calendar_repository.dart';

import '../../../helpers/isar_test_harness.dart';

CalendarEventModel _event(
  String title,
  DateTime start, {
  EventRepeat repeat = EventRepeat.none,
}) => CalendarEventModel()
  ..title = title
  ..startDateTime = start
  ..repeat = repeat;

void main() {
  late IsarTestHarness harness;
  late CalendarRepository repo;

  setUp(() async {
    harness = await IsarTestHarness.create();
    repo = CalendarRepositoryImpl(harness.isar);
  });

  tearDown(() => harness.dispose());

  test('create/get/update/delete an event', () async {
    final int id = (await repo.createEvent(
      _event('Standup', DateTime(2026, 2, 1, 9)),
    )).dataOrNull!;
    expect((await repo.getEventById(id)).dataOrNull?.title, 'Standup');

    final CalendarEventModel loaded = (await repo.getEventById(id)).dataOrNull!;
    await repo.updateEvent(loaded..description = 'Daily sync');
    expect((await repo.getEventById(id)).dataOrNull?.description, 'Daily sync');

    await repo.deleteEvent(id);
    expect(await repo.getEventById(id), isA<Error<CalendarEventModel>>());
  });

  test('watchEventsForDay returns only events on the given day', () async {
    await repo.createEvent(_event('Day 1', DateTime(2026, 3, 1, 8)));
    await repo.createEvent(_event('Day 1 late', DateTime(2026, 3, 1, 20)));
    await repo.createEvent(_event('Day 2', DateTime(2026, 3, 2, 8)));

    final List<CalendarEventModel> day = await repo
        .watchEventsForDay(DateTime(2026, 3, 1))
        .first;
    expect(day.map((CalendarEventModel e) => e.title), <String>[
      'Day 1',
      'Day 1 late',
    ]);
  });

  test(
    'watchUpcomingEvents returns future events, soonest first, capped by limit',
    () async {
      final DateTime now = DateTime.now();
      await repo.createEvent(
        _event('Past', now.subtract(const Duration(days: 1))),
      );
      await repo.createEvent(_event('Soon', now.add(const Duration(hours: 1))));
      await repo.createEvent(
        _event('Later', now.add(const Duration(hours: 2))),
      );
      await repo.createEvent(
        _event('Latest', now.add(const Duration(hours: 3))),
      );

      final List<CalendarEventModel> upcoming = await repo
          .watchUpcomingEvents()
          .first;
      expect(upcoming.map((CalendarEventModel e) => e.title), <String>[
        'Soon',
        'Later',
        'Latest',
      ]);
    },
  );
}
