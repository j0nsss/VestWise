import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:vestwise/app.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/core/database/isar_service.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';

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
    await tester.pumpAndSettle();
  }

  Finder navDestination(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );

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
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('New task'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Integration Task',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create task'));
    await tester.pumpAndSettle();

    expect(find.text('Integration Task'), findsOneWidget);
  });

  testWidgets('logs an expense and updates the balance', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(navDestination('Finance'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Add transaction'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '100',
    );
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('writes a note and sees it persisted', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(navDestination('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('No notes yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Integration Note',
    );
    // Let the 800ms autosave debounce fire, then flush on pop.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Integration Note'), findsOneWidget);
  });
}
