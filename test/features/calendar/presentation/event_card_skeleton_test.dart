import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_card_skeleton.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_list_tile.dart';

import '../../../helpers/scroll_contexts.dart';

CalendarEventModel _event() => CalendarEventModel()
  ..id = 1
  ..title = 'Dentist'
  ..startDateTime = DateTime(2026, 3, 4, 15, 30)
  ..repeat = EventRepeat.none;

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  ),
);

void main() {
  group('EventCardSkeleton (P11-T1)', () {
    testWidgets('occupies the same card the real event will', (
      WidgetTester tester,
    ) async {
      await _pump(tester, EventListTile(event: _event()));
      final double real = tester.getSize(find.byType(EventListTile)).height;

      await _pump(tester, const EventCardSkeleton());
      final double skeleton = tester
          .getSize(find.byType(EventCardSkeleton))
          .height;

      expect(
        (real - skeleton).abs(),
        lessThanOrEqualTo(3),
        reason: 'real $real vs skeleton $skeleton',
      );
    });

    testWidgets('survives the scroll contexts that bit this project once', (
      WidgetTester tester,
    ) async {
      await expectSurvivesScrollContexts(
        tester,
        const EventCardSkeleton(),
        EventCardSkeleton,
      );
    });
  });
}
