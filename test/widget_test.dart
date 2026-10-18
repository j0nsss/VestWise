import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/app.dart';
import 'package:vestwise/core/router/app_shell.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:vestwise/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:vestwise/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/screens/tasks_list_screen.dart';

void main() {
  // Widget tests inject already-resolved, empty streams so lists settle without
  // touching the native Isar core (which would hang the fake-async test clock
  // and leave a loading spinner animating forever).
  Widget app() => ProviderScope(
        overrides: [
          watchAllTasksProvider
              .overrideWith((Ref ref) => Stream<List<TaskModel>>.value(<TaskModel>[])),
          watchAllEventsProvider.overrideWith(
            (Ref ref) => Stream<List<CalendarEventModel>>.value(
              <CalendarEventModel>[],
            ),
          ),
          dashboardProvider.overrideWith(
            (Ref ref) => const DashboardState.empty(),
          ),
        ],
        child: const VestWiseApp(),
      );

  testWidgets('app boots to the Dashboard tab', (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('bottom navigation switches between tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.byType(TasksListScreen), findsOneWidget);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);
  });

  test('AppTheme exposes a light and dark Material 3 theme', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  group('shell branch settle (P9-T3)', () {
    double? settleOpacity(WidgetTester tester) {
      final Finder fade = find.byKey(appShellSettleKey);
      if (fade.evaluate().isEmpty) {
        return null;
      }

      return tester.widget<FadeTransition>(fade).opacity.value;
    }

    testWidgets('switching tabs settles in rather than hard-cutting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(settleOpacity(tester), 1);

      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(settleOpacity(tester), lessThan(1));

      await tester.pumpAndSettle();
      expect(settleOpacity(tester), 1);
      expect(find.byType(TasksListScreen), findsOneWidget);
    });

    testWidgets('reduced motion drops the settle altogether', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(settleOpacity(tester), isNull);

      await tester.tap(find.text('Tasks'));
      await tester.pump();

      expect(settleOpacity(tester), isNull);
      expect(find.byType(TasksListScreen), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
