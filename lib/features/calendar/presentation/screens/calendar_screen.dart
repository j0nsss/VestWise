import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_notification_banner.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_list_tile.dart';

/// Month grid with per-day event markers plus a selected-day event list
/// (plan P3-CAL-1).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<CalendarEventModel> allEvents =
        ref.watch(watchAllEventsProvider).value ?? <CalendarEventModel>[];
    final Map<DateTime, List<CalendarEventModel>> byDay = _groupByDay(allEvents);

    return Scaffold(
      appBar: const VWAppBar(title: AppStrings.calendar),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RoutePaths.eventDetailFor(RoutePaths.newId)),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          const VWNotificationBanner(),
          TableCalendar<CalendarEventModel>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2035),
            focusedDay: _focusedDay,
            selectedDayPredicate: (DateTime day) => isSameDay(_selectedDay, day),
            eventLoader: (DateTime day) => _eventsForDay(byDay, day),
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (DateTime focusedDay) => _focusedDay = focusedDay,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat.yMMMMEEEEd().format(_selectedDay),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(child: _buildDayList(byDay)),
        ],
      ),
    );
  }

  Widget _buildDayList(Map<DateTime, List<CalendarEventModel>> byDay) {
    final List<CalendarEventModel> events = _eventsForDay(byDay, _selectedDay);

    if (events.isEmpty) {
      return const VWEmptyState(
        icon: Icons.event_available_outlined,
        message: 'No events on this day.',
      );
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        final CalendarEventModel event = events[index];
        return EventListTile(
          event: event,
          onTap: () => context.go(RoutePaths.eventDetailFor(event.id)),
        );
      },
    );
  }

  Map<DateTime, List<CalendarEventModel>> _groupByDay(
    List<CalendarEventModel> events,
  ) {
    final Map<DateTime, List<CalendarEventModel>> map =
        <DateTime, List<CalendarEventModel>>{};
    for (final CalendarEventModel event in events) {
      final DateTime key = DateTime(
        event.startDateTime.year,
        event.startDateTime.month,
        event.startDateTime.day,
      );
      map.putIfAbsent(key, () => <CalendarEventModel>[]).add(event);
    }
    return map;
  }

  List<CalendarEventModel> _eventsForDay(
    Map<DateTime, List<CalendarEventModel>> byDay,
    DateTime day,
  ) =>
      byDay[DateTime(day.year, day.month, day.day)] ?? <CalendarEventModel>[];
}
