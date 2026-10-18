import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_list_tile.dart';

CalendarEventModel _event({
  int id = 1,
  String title = 'Dentist',
  DateTime? start,
  DateTime? end,
  bool isAllDay = false,
  int colorValue = 0xFF4F46E5,
}) {
  return CalendarEventModel()
    ..id = id
    ..title = title
    ..startDateTime = start ?? DateTime(2026, 3, 4, 15, 30)
    ..endDateTime = end
    ..isAllDay = isAllDay
    ..repeat = EventRepeat.none
    ..colorValue = colorValue;
}

Future<void> _pump(WidgetTester tester, Widget child, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    ),
  );
}

Color _barColor(WidgetTester tester) {
  final Finder bar = find.descendant(
    of: find.byType(EventListTile),
    matching: find.byType(ExcludeSemantics),
  );
  final Container container = tester.widget<Container>(
    find.descendant(of: bar, matching: find.byType(Container)).first,
  );

  return (container.color)!;
}

void main() {
  group('EventListTile (P10-CAL-2)', () {
    testWidgets('renders as a flat card, not a bare ListTile', (
      WidgetTester tester,
    ) async {
      await _pump(tester, EventListTile(event: _event()));

      final VWCard card = tester.widget<VWCard>(find.byType(VWCard));
      expect(card.variant, VWCardVariant.flat);
      expect(card.padding, EdgeInsets.zero);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('the accent bar carries the event colour', (
      WidgetTester tester,
    ) async {
      await _pump(tester, EventListTile(event: _event(colorValue: 0xFF00897B)));

      expect(_barColor(tester), const Color(0xFF00897B));
      expect(
        tester
            .getSize(
              find.descendant(
                of: find.byType(EventListTile),
                matching: find.byType(Container),
              ),
            )
            .width,
        EventListTile.accentWidth,
      );
    });

    testWidgets('two events with different colours look different', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        Column(
          children: <Widget>[
            EventListTile(event: _event(id: 1, colorValue: 0xFF00897B)),
            EventListTile(
              event: _event(id: 2, title: 'Standup', colorValue: 0xFFD81B60),
            ),
          ],
        ),
      );

      final List<Color> bars = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(EventListTile),
              matching: find.byType(Container),
            ),
          )
          .map((Container container) => container.color!)
          .toList();
      expect(bars, <Color>[const Color(0xFF00897B), const Color(0xFFD81B60)]);
    });

    testWidgets('legibility does not depend on the event colour', (
      WidgetTester tester,
    ) async {
      // A deliberately loud colour: the text must not follow it.
      final CalendarEventModel event = _event(colorValue: 0xFFFFEB3B);

      for (final bool dark in <bool>[false, true]) {
        await _pump(tester, EventListTile(event: event), dark: dark);

        final BuildContext context = tester.element(find.byType(VWCard));
        final ThemeData theme = Theme.of(context);
        expect(
          tester.widget<Text>(find.text('Dentist')).style?.color ??
              theme.textTheme.titleSmall?.color,
          theme.colorScheme.onSurface,
        );
        final Text time = tester.widget<Text>(
          find.text(DateFormat.jm().format(event.startDateTime)),
        );
        expect(time.style?.color, theme.colorScheme.onSurfaceVariant);
      }
    });

    testWidgets('time labels cover all-day, bare start and a range', (
      WidgetTester tester,
    ) async {
      await _pump(tester, EventListTile(event: _event(isAllDay: true)));
      expect(find.text('All day'), findsOneWidget);

      // Locale-safe: the tile formats with `DateFormat.jm()`, so the test does
      // too instead of hard-coding "3:30 PM".
      final DateTime start = DateTime(2026, 3, 4, 15, 30);
      await _pump(tester, EventListTile(event: _event()));
      expect(find.text(DateFormat.jm().format(start)), findsOneWidget);

      final DateTime end = DateTime(2026, 3, 4, 17);
      await _pump(tester, EventListTile(event: _event(end: end)));
      expect(
        find.text(
          '${DateFormat.jm().format(start)} – ${DateFormat.jm().format(end)}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping the card still opens the event', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await _pump(tester, EventListTile(event: _event(), onTap: () => taps++));

      await tester.tap(find.byType(VWCard));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('the row is announced as one thing', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        EventListTile(
          event: _event(title: 'Dentist'),
          onTap: () {},
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Dentist')),
        findsOneWidget,
        reason: 'title and time are merged into a single node',
      );
    });
  });
}
