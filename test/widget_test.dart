import 'dart:ui' show Tristate;

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

  // Phase 14's dock paints no labels — the destination names survive only as
  // semantics, so the tests tap and assert through that.
  Finder dockItem(String label) => find.descendant(
    of: find.byKey(appShellDockKey),
    matching: find.bySemanticsLabel(label),
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
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(dockItem('Tasks'));
    await tester.pumpAndSettle();
    expect(find.byType(TasksListScreen), findsOneWidget);

    await tester.tap(dockItem('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);

    handle.dispose();
  });

  group('floating dock (P14)', () {
    testWidgets('all five destinations still navigate', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

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
        await tester.tap(dockItem(label));
        await tester.pumpAndSettle();

        expect(
          find.byType(screen).hitTestable(),
          findsOneWidget,
          reason: '$label tab',
        );
      }

      expect(find.byType(TasksListScreen).hitTestable(), findsNothing);
      expect(find.byType(NotesListScreen).hitTestable(), findsNothing);

      handle.dispose();
    });

    testWidgets('the dock is blurred glass and lights the active item', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final ColorScheme scheme = Theme.of(
        tester.element(find.byKey(appShellDockKey)),
      ).colorScheme;

      expect(tester.getSize(find.byKey(appShellDockKey)).height, 64);
      expect(
        find.descendant(
          of: find.byKey(appShellDockKey),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );

      // The active destination is an amber filled circle behind its icon; the
      // idle ones are transparent discs of the same size.
      BoxDecoration discOf(String label) {
        final Container box = tester.widget<Container>(
          find.descendant(
            of: dockItem(label),
            matching: find.byType(Container),
          ),
        );

        return box.decoration! as BoxDecoration;
      }

      expect(discOf('Home').color, scheme.secondary);
      expect(discOf('Tasks').color, Colors.transparent);

      // And the state is announced, not only painted.
      expect(
        tester.getSemantics(dockItem('Home')).flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(
        tester.getSemantics(dockItem('Tasks')).flagsCollection.isSelected,
        Tristate.isFalse,
      );

      handle.dispose();
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
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(settleOpacity(tester), 1);

      await tester.tap(dockItem('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(settleOpacity(tester), lessThan(1));

      await tester.pumpAndSettle();
      expect(settleOpacity(tester), 1);
      expect(find.byType(TasksListScreen), findsOneWidget);

      handle.dispose();
    });

    testWidgets('reduced motion drops the settle altogether', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(settleOpacity(tester), isNull);

      await tester.tap(dockItem('Tasks'));
      await tester.pump();

      expect(settleOpacity(tester), isNull);
      expect(find.byType(TasksListScreen), findsOneWidget);

      await tester.pumpAndSettle();
      handle.dispose();
    });
  });
}
