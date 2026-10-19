import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_delayed.dart';
import 'package:vestwise/core/widgets/vw_fade_through.dart';
import 'package:vestwise/core/widgets/vw_fab.dart';
import 'package:vestwise/core/widgets/vw_luminous.dart';
import 'package:vestwise/core/widgets/vw_screen_header.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';
import 'package:vestwise/core/widgets/vw_notification_banner.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_list_tile.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_card_skeleton.dart';

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
    final AsyncValue<List<CalendarEventModel>> eventsAsync = ref.watch(
      watchAllEventsProvider,
    );
    // Grid markers degrade to none while loading or on error — the day list
    // below carries the explicit loading/error state (P5-T2).
    final Map<DateTime, List<CalendarEventModel>> byDay = _groupByDay(
      eventsAsync.value ?? const <CalendarEventModel>[],
    );

    return Scaffold(
      floatingActionButton: VWFab(
        tooltip: 'Add event',
        onPressed: () =>
            context.go(RoutePaths.eventDetailFor(RoutePaths.newId)),
        child: const Icon(Icons.add),
      ),
      // One comfortable gap over the floating dock (Phase 13).
      floatingActionButtonLocation: const VWFabLocation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const VWScreenHeader(title: AppStrings.calendar),
            const VWNotificationBanner(),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: TableCalendar<CalendarEventModel>(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2035),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (DateTime day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: (DateTime day) => _eventsForDay(byDay, day),
                      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (DateTime focusedDay) =>
                          _focusedDay = focusedDay,
                      headerStyle: _headerStyle(theme),
                      daysOfWeekStyle: _daysOfWeekStyle(theme),
                      calendarStyle: _calendarStyle(theme),
                    ),
                  ),
                  SliverToBoxAdapter(child: _agendaHeader(theme, byDay)),
                  SliverFillRemaining(
                    child: VWFadeThrough(
                        child: eventsAsync.when(
                          loading: () => const VWDelayed(
                            key: ValueKey<String>('day-loading'),
                            // Same gutter and card gaps as the real day list
                            // below.
                            child: VWSkeletonList(
                              row: EventCardSkeleton(),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              gap: AppSpacing.sm,
                            ),
                          ),
                          error: (Object error, StackTrace stack) =>
                              VWEmptyState(
                                key: const ValueKey<String>('day-error'),
                                icon: Icons.error_outline,
                                title: 'Could not load your events',
                                message:
                                    'Something went wrong reading your calendar.',
                                actionLabel: 'Retry',
                                onAction: () =>
                                    ref.invalidate(watchAllEventsProvider),
                              ),
                          data: (List<CalendarEventModel> events) =>
                              _buildDayList(_groupByDay(events)),
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The mockup's "active schedule" strip: the mint pulse dot + uppercase
  /// micro-label, the selected date as the headline, and a quiet pill on the
  /// right with how many events the day actually holds.
  Widget _agendaHeader(ThemeData theme, Map<DateTime, List<CalendarEventModel>> byDay) {
    final List<CalendarEventModel> events = _eventsForDay(byDay, _selectedDay);
    final int count = events.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'ACTIVE SCHEDULE',
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat.yMMMMEEEEd().format(_selectedDay),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: AppRadii.chip,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$count Event${count == 1 ? '' : 's'}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Flat month header (plan P10-CAL-1): no card, no divider, quiet chevrons
  /// and a month label that lines up with the day list's gutter below it.
  ///
  /// The stock header hard-codes a 17px `TextStyle` and grey icons, so every
  /// value here comes from a token instead. `formatButtonVisible` is off
  /// deliberately: the format button only renders when more than one calendar
  /// format is offered, and this app only ever uses the month grid — the flag
  /// documents that rather than removing a control.
  HeaderStyle _headerStyle(ThemeData theme) {
    return HeaderStyle(
      titleCentered: false,
      formatButtonVisible: false,
      headerPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      titleTextStyle: theme.textTheme.titleMedium!,
      leftChevronIcon: Icon(
        Icons.chevron_left,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      rightChevronIcon: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Weekend days are not a special colour: the stock style tints them red,
  /// which fights every other colour on this screen.
  DaysOfWeekStyle _daysOfWeekStyle(ThemeData theme) {
    final TextStyle weekday = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return DaysOfWeekStyle(weekdayStyle: weekday, weekendStyle: weekday);
  }

  /// The mockup's day states: the selected day is a filled primary-container
  /// circle with the violet glow, today is a ring, and the event markers pick
  /// up the mint accent. "Selected" and "today" stay distinguishable even when
  /// they are the same day.
  CalendarStyle _calendarStyle(ThemeData theme) {
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle neighbourhood = theme.textTheme.bodyMedium!.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: vwGlowShadow(alpha: 0.4, offsetY: 4),
      ),
      selectedTextStyle: theme.textTheme.titleMedium!.copyWith(
        color: scheme.onPrimaryContainer,
        fontWeight: FontWeight.w700,
      ),
      todayDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: scheme.primary),
      ),
      todayTextStyle: neighbourhood.copyWith(color: scheme.primary),
      defaultTextStyle: neighbourhood.copyWith(color: scheme.onSurface),
      outsideTextStyle: neighbourhood,
      disabledTextStyle: theme.textTheme.bodyMedium!.copyWith(
        color: scheme.outline,
      ),
      weekendTextStyle: neighbourhood.copyWith(color: scheme.onSurface),
      markerDecoration: BoxDecoration(
        color: scheme.secondary,
        shape: BoxShape.circle,
      ),
      markersMaxCount: 3,
    );
  }

  Widget _buildDayList(Map<DateTime, List<CalendarEventModel>> byDay) {
    final List<CalendarEventModel> events = _eventsForDay(byDay, _selectedDay);

    if (events.isEmpty) {
      return const VWEmptyState(
        key: ValueKey<String>('day-empty'),
        icon: Icons.event_available_outlined,
        message: 'No events on this day.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        vwDockClearance,
      ),
      itemCount: events.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppSpacing.sm),
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
  ) => byDay[DateTime(day.year, day.month, day.day)] ?? <CalendarEventModel>[];
}
