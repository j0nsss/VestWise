import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vestwise/app.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/core/database/isar_service.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/core/theme/theme_store.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';

/// On-device end-to-end smoke tests for the Phase 3 modules (plan P6-T3).
///
/// These run against a *real* Isar database and the real plugin stack
/// (`flutter test integration_test -d <device>`), so they validate the things
/// unit/widget tests cannot: native storage, the notification plugin channel,
/// and the go_router shell under a real event loop.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;

  setUpAll(() async {
    isar = await openIsar();
  });

  setUp(() async {
    // Deterministic starting point for every scenario.
    await isar.writeTxn(() => isar.clear());
    await FinanceRepositoryImpl(isar).seedDefaultCategories();
  });

  Finder navDestination(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );

  /// Like `pumpAndSettle`, but fails after [timeout] instead of the 10-minute
  /// default, so a screen that never settles surfaces its own error quickly.
  Future<void> settle(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 20),
  }) =>
      tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        timeout,
      );

  /// Pumps frames until [finder] matches or [timeout] elapses. Needed after
  /// writes because Isar `watch` streams (especially the finance one, which
  /// `asyncMap`s to load links) emit on the real event loop, not synchronously.
  Future<void> settleUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final DateTime deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    final List<String> visible = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text t) => t.data ?? '')
        .where((String s) => s.isNotEmpty)
        .toList();
    fail('Timed out waiting for: $finder\nVisible text: $visible');
  }

  Future<void> pumpApp(WidgetTester tester) async {
    final NotificationService notifications = NotificationService();
    await notifications.init();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(AsyncValue<Isar>.data(isar)),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
        child: const VestWiseApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('boots to the dashboard with empty cards', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.textContaining('Good'), findsWidgets);
    expect(find.text("Today's tasks"), findsOneWidget);
    expect(find.text('Finance'), findsWidgets);
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('creates a task and sees it in the list', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(navDestination('Tasks'));
    await settle(tester);
    expect(find.text('No tasks yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await settle(tester);
    expect(find.text('New task'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Integration Task',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create task'));
    await settle(tester);

    await settleUntilFound(tester, find.text('Integration Task'));
  });

  testWidgets('logs an expense and updates the balance', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(navDestination('Finance'));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.add));
    await settle(tester);
    expect(find.text('Add transaction'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '100',
    );
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await settle(tester);
    await tester.tap(find.text('Food').last);
    await settle(tester);
    expect(
      find.text('Food'),
      findsOneWidget,
      reason: 'category should be selected in the dropdown',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add transaction'));
    await settle(tester);

    await settleUntilFound(tester, find.text('Food'));
    // A 100 expense leaves the balance at -100.00; both the balance card and
    // the transaction tile show the signed amount. Format through the app's own
    // formatter so the assertion is independent of the device locale.
    expect(find.text('Current balance'), findsOneWidget);
    expect(find.text('-${formatMoney(100)}'), findsWidgets);
  });

  testWidgets('writes a note and sees it persisted', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(navDestination('Notes'));
    await settle(tester);
    expect(find.text('No notes yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await settle(tester);
    expect(find.text('New note'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Integration Note',
    );
    // Let the 800ms autosave debounce fire, then flush on pop.
    await tester.pump(const Duration(milliseconds: 1000));
    await settle(tester);

    await tester.pageBack();
    await settle(tester);

    await settleUntilFound(tester, find.text('Integration Note'));
  });

  testWidgets('changes the theme and clears all data from Settings', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    // Give the reset something to remove.
    await tester.tap(navDestination('Tasks'));
    await settle(tester);
    await tester.tap(find.byIcon(Icons.add));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Doomed task',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create task'));
    await settle(tester);
    await settleUntilFound(tester, find.text('Doomed task'));

    // Settings lives behind the dashboard app bar.
    await tester.tap(navDestination('Dashboard'));
    await settle(tester);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await settleUntilFound(tester, find.text('Appearance'));

    // Choosing a theme writes it to disk, so the next launch paints the same
    // theme instead of flashing the default.
    await tester.tap(find.text('Dark'));
    await settle(tester);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ThemeStore.key), 'dark');

    // Clear-all asks first, then empties the database.
    await tester.tap(find.text('Clear all data'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Clear all data'));
    await settleUntilFound(tester, find.text('All local data cleared.'));

    await tester.tap(navDestination('Tasks'));
    await settle(tester);
    await settleUntilFound(tester, find.text('No tasks yet'));

    // Leave the device on the default theme for the next run.
    await tester.tap(navDestination('Dashboard'));
    await settle(tester);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.tap(find.text('System'));
    await settle(tester);
  });
}
