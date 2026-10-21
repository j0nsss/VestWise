import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/app.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/router/app_shell.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:vestwise/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:vestwise/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/screens/finance_home_screen.dart';
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
      // The Settings screen reports on reminders; without these two it would
      // call the notification plugin from a widget test.
      notificationsBlockedProvider.overrideWith((Ref ref) => false),
      notificationStatusProvider.overrideWith(
        (Ref ref) => const NotificationStatus(
          permissionRequested: false,
          enabled: false,
          exactAlarmsAllowed: false,
        ),
      ),
    ],
    child: const VestWiseApp(),
  );

  testWidgets('app boots to the Dashboard tab', (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byKey(appShellDockKey), findsOneWidget);
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

  group('floating dock (P13)', () {
    Finder dockLabel(String label) => find.descendant(
      of: find.byKey(appShellDockKey),
      matching: find.text(label),
    );

    testWidgets('all five destinations still navigate', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // `IndexedStack` keeps visited branches alive, so what proves the switch
      // is which branch is actually hit-testable — a bare `findsOneWidget`
      // would pass for a tab that is no longer visible.
      final List<(String, Type)> tabs = <(String, Type)>[
        ('Finance', FinanceHomeScreen),
        ('Notes', NotesListScreen),
        ('Tasks', TasksListScreen),
        ('Calendar', CalendarScreen),
        ('Home', DashboardScreen),
      ];

      for (final (String label, Type screen) in tabs) {
        await tester.tap(dockLabel(label));
        await tester.pumpAndSettle();

        expect(
          find.byType(screen).hitTestable(),
          findsOneWidget,
          reason: '$label tab',
        );
      }

      expect(find.byType(TasksListScreen).hitTestable(), findsNothing);
      expect(find.byType(NotesListScreen).hitTestable(), findsNothing);
    });

    testWidgets('the dock is blurred glass and lights the active item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byKey(appShellDockKey),
      );
      final ColorScheme scheme = Theme.of(context).colorScheme;

      expect(tester.getSize(find.byKey(appShellDockKey)).height, 64);
      expect(
        find.descendant(
          of: find.byKey(appShellDockKey),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );

      final TextStyle active = tester.widget<Text>(
        dockLabel('Home'),
      ).style!;
      final TextStyle idle = tester.widget<Text>(
        dockLabel('Tasks'),
      ).style!;
      expect(active.color, scheme.primary);
      expect(active.fontWeight, FontWeight.w700);
      expect(idle.color, scheme.onSurfaceVariant);
      expect(idle.fontWeight, FontWeight.w500);
    });

    testWidgets('the dock floats clear of the page edges', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final Positioned host = tester.widget<Positioned>(
        find
            .ancestor(
              of: find.byKey(appShellDockKey),
              matching: find.byType(Positioned),
            )
            .first,
      );

      expect(host.left, AppSpacing.lg);
      expect(host.right, AppSpacing.lg);
      expect(host.bottom, AppSpacing.lg);
    });
  });

  test('AppTheme exposes a light and dark Material 3 theme', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  group('settings route (P12-T4)', () {
    testWidgets('is pushed on top of the shell, not swapped for it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);

      // A pushed route has a route beneath it, which is where the implied back
      // button comes from — without it there is no way off the page, and the
      // system back button exits the app.
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byKey(appShellDockKey), findsOneWidget);
    });
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
