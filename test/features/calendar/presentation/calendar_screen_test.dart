import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/calendar/presentation/screens/calendar_screen.dart';

Future<void> _pumpCalendar(WidgetTester tester, {required bool dark}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        watchAllEventsProvider.overrideWith(
          (Ref ref) => Stream<List<CalendarEventModel>>.value(
            const <CalendarEventModel>[],
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: const CalendarScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TableCalendar<CalendarEventModel> _calendar(WidgetTester tester) =>
    tester.widget<TableCalendar<CalendarEventModel>>(
      find.byType(TableCalendar<CalendarEventModel>),
    );

ThemeData _theme(WidgetTester tester) => Theme.of(
      tester.element(find.byType(TableCalendar<CalendarEventModel>)),
    );

void main() {
  group('calendar header (P10-CAL-1)', () {
    testWidgets('the header is flat and takes its type from the theme', (
      WidgetTester tester,
    ) async {
      await _pumpCalendar(tester, dark: false);

      final HeaderStyle header = _calendar(tester).headerStyle;
      final ThemeData theme = _theme(tester);

      expect(header.titleTextStyle, theme.textTheme.titleMedium);
      expect(
        header.decoration,
        const BoxDecoration(),
        reason: 'no card or divider chrome around the header',
      );
      expect(
        header.formatButtonVisible,
        isFalse,
        reason: 'the app only offers the month grid, so there is nothing to '
            'switch between',
      );
      final Icon left = header.leftChevronIcon as Icon;
      expect(left.icon, Icons.chevron_left);
      expect(left.color, theme.colorScheme.onSurfaceVariant);
      final Icon right = header.rightChevronIcon as Icon;
      expect(right.color, theme.colorScheme.onSurfaceVariant);
    });

    testWidgets('weekend days are not tinted red', (
      WidgetTester tester,
    ) async {
      await _pumpCalendar(tester, dark: false);

      final DaysOfWeekStyle dow = _calendar(tester).daysOfWeekStyle;
      final ThemeData theme = _theme(tester);

      expect(dow.weekendStyle.color, theme.colorScheme.onSurfaceVariant);
      expect(dow.weekendStyle.color, dow.weekdayStyle.color);
    });

    testWidgets('today is a ring and the selected day a filled circle', (
      WidgetTester tester,
    ) async {
      await _pumpCalendar(tester, dark: false);

      final CalendarStyle style = _calendar(tester).calendarStyle;
      final ColorScheme scheme = _theme(tester).colorScheme;

      // Different shapes, not just different colours, so the two stay
      // distinguishable on the day that is both today and selected.
      final BoxDecoration today = style.todayDecoration as BoxDecoration;
      final BoxDecoration selected = style.selectedDecoration as BoxDecoration;
      expect(today.color, isNull);
      expect(today.border?.top.color, scheme.primary);
      expect(selected.color, scheme.primary);
      expect(selected.shape, BoxShape.circle);
      // Each text colour is the pair that belongs to its fill.
      expect(style.todayTextStyle.color, scheme.primary);
      expect(style.selectedTextStyle.color, scheme.onPrimary);
      expect((style.markerDecoration as BoxDecoration).color, scheme.primary);
    });

    testWidgets('day text colours come from the scheme in both themes', (
      WidgetTester tester,
    ) async {
      for (final bool dark in <bool>[false, true]) {
        await _pumpCalendar(tester, dark: dark);

        final CalendarStyle style = _calendar(tester).calendarStyle;
        final ColorScheme scheme = _theme(tester).colorScheme;

        expect(style.selectedTextStyle.color, scheme.onPrimary);
        expect(style.todayTextStyle.color, scheme.primary);
        expect(style.defaultTextStyle.color, scheme.onSurface);
        expect(style.outsideTextStyle.color, scheme.onSurfaceVariant);
        expect(style.disabledTextStyle.color, scheme.outline);
      }
    });

    testWidgets('the grid is no longer separated from the list by a rule', (
      WidgetTester tester,
    ) async {
      await _pumpCalendar(tester, dark: false);

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('month navigation still works', (
      WidgetTester tester,
    ) async {
      await _pumpCalendar(tester, dark: false);

      final DateTime now = DateTime.now();
      expect(
        find.text(DateFormat.yMMMM().format(now)),
        findsOneWidget,
        reason: 'the current month is the one the calendar opens on',
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(
        find.text(DateFormat.yMMMM().format(DateTime(now.year, now.month + 1))),
        findsOneWidget,
      );
      expect(find.text(DateFormat.yMMMM().format(now)), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text(DateFormat.yMMMM().format(now)), findsOneWidget);
    });
  });
}
