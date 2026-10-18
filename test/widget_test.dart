import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/app.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/router/app_shell.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:vestwise/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:vestwise/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/notes/presentation/screens/notes_list_screen.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/screens/tasks_list_screen.dart';

void main() {
  // Widget tests inject already-resolved, empty streams so lists settle without
  // touching the native Isar core (which would hang the fake-async test clock
  // and leave a loading spinner animating forever).
  Widget app() => ProviderScope(
    overrides: [
      watchAllTasksProvider.overrideWith(
        (Ref ref) => Stream<List<TaskModel>>.value(<TaskModel>[]),
      ),
      watchAllEventsProvider.overrideWith(
        (Ref ref) =>
            Stream<List<CalendarEventModel>>.value(<CalendarEventModel>[]),
      ),
      dashboardProvider.overrideWith((Ref ref) => const DashboardState.empty()),
      // The bar test walks every tab, so the two branches it did not use
      // before need empty data too — a real Isar read inside the fake-async
      // clock is what hangs this file.
      watchRecentTransactionsProvider.overrideWith(
        (Ref ref, int limit) =>
            Stream<List<TransactionModel>>.value(<TransactionModel>[]),
      ),
      balanceProvider.overrideWith((Ref ref) => 0.0),
      watchNotesMatchingProvider.overrideWith(
        (Ref ref, String query) => Stream<List<NoteModel>>.value(<NoteModel>[]),
      ),
      watchImportedDocumentsProvider.overrideWith(
        (Ref ref) => Stream<List<ImportedDocumentModel>>.value(
          <ImportedDocumentModel>[],
        ),
      ),
      importedFilesSizeProvider.overrideWith((Ref ref) => 0),
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

  group('bottom bar (P10-NAV-1)', () {
    NavigationBar bar(WidgetTester tester) =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    testWidgets('all five destinations still navigate', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // `IndexedStack` keeps visited branches alive, so what proves the switch
      // is the selected index plus which branch is actually hit-testable — a
      // bare `findsOneWidget` would pass for a tab that is no longer visible.
      final List<(String, int)> tabs = <(String, int)>[
        ('Finance', 1),
        ('Notes', 2),
        ('Tasks', 3),
        ('Calendar', 4),
        ('Dashboard', 0),
      ];

      for (final (String label, int index) in tabs) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();

        expect(bar(tester).selectedIndex, index, reason: '$label tab');
      }

      expect(find.byType(DashboardScreen).hitTestable(), findsOneWidget);
      expect(find.byType(TasksListScreen).hitTestable(), findsNothing);
      expect(find.byType(NotesListScreen).hitTestable(), findsNothing);
    });

    testWidgets('the bar is flat and takes its colours from the theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final ThemeData theme = Theme.of(
        tester.element(find.byType(NavigationBar)),
      );
      final NavigationBarThemeData navTheme = theme.navigationBarTheme;

      expect(navTheme.backgroundColor, theme.colorScheme.surface);
      expect(navTheme.elevation, AppElevation.flat);
      expect(navTheme.surfaceTintColor, Colors.transparent);
      expect(
        navTheme.indicatorColor,
        theme.colorScheme.primary.withValues(alpha: 0.12),
      );
      expect(tester.getSize(find.byType(NavigationBar)).height, 64);

      final IconThemeData? selected = navTheme.iconTheme!.resolve(<WidgetState>{
        WidgetState.selected,
      });
      final IconThemeData? unselected = navTheme.iconTheme!.resolve(
        const <WidgetState>{},
      );
      expect(selected?.color, theme.colorScheme.primary);
      expect(unselected?.color, theme.colorScheme.onSurfaceVariant);

      final TextStyle? selectedLabel = navTheme.labelTextStyle!.resolve(
        <WidgetState>{WidgetState.selected},
      );
      final TextStyle? unselectedLabel = navTheme.labelTextStyle!.resolve(
        const <WidgetState>{},
      );
      expect(selectedLabel?.color, theme.colorScheme.primary);
      expect(selectedLabel?.fontWeight, FontWeight.w600);
      expect(unselectedLabel?.color, theme.colorScheme.onSurfaceVariant);
    });

    testWidgets('the bar is separated from the page by a hairline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(NavigationBar));
      final DecoratedBox wrapper = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byType(NavigationBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final BoxDecoration decoration = wrapper.decoration as BoxDecoration;

      expect(decoration.border?.top.color, AppColors.borderSubtle(context));
      expect(decoration.border?.top.width, 1);
      expect(
        decoration.color,
        isNull,
        reason: 'the bar paints its own surface colour',
      );
    });
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
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

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
