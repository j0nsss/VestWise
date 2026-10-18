import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_card_skeleton.dart';
import 'package:vestwise/features/calendar/presentation/widgets/event_list_tile.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/screens/finance_home_screen.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_list_tile.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_row_skeleton.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/notes/presentation/screens/notes_list_screen.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_card_skeleton.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_list_tile.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/screens/tasks_list_screen.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_list_tile.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_row_skeleton.dart';

/// How long the gate holds a skeleton back. Assertions use this either side.
const Duration _gate = Duration(milliseconds: 150);

TaskModel _task() => TaskModel()
  ..id = 1
  ..title = 'Write the report'
  ..priority = TaskPriority.medium
  ..createdAt = DateTime(2026, 3, 1);

TransactionModel _transaction() => TransactionModel()
  ..id = 1
  ..amount = 12.5
  ..type = TransactionType.expense
  ..date = DateTime(2026, 3, 1)
  ..createdAt = DateTime(2026, 3, 1)
  ..note = 'Lunch'
  ..category.value = (CategoryModel()
    ..id = 1
    ..name = 'Food'
    ..iconCodePoint = Icons.restaurant.codePoint
    ..colorValue = 0
    ..type = TransactionType.expense);

NoteModel _note() => NoteModel()
  ..id = 1
  ..title = 'Grocery list'
  ..contentJson = '{}'
  ..contentPlainText = 'Milk and eggs'
  ..createdAt = DateTime(2026, 3, 1)
  ..updatedAt = DateTime(2026, 3, 1);

CalendarEventModel _event() => CalendarEventModel()
  ..id = 1
  ..title = 'Dentist'
  ..startDateTime = DateTime.now()
  ..repeat = EventRepeat.none;

/// Pumps the app to its first frame — never `pumpAndSettle`, because a
/// skeleton's shimmer repeats forever and would never settle.
Future<void> _pump(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pump();
}

/// Deliberately never `pumpAndSettle`s while a skeleton is on screen — a
/// shimmer repeats forever, so settling would time out. That is also why the
/// gate is worth testing at all: it is what keeps that loop off screen for the
/// ordinary fast read.
void main() {
  group('list loading states (P11-T2)', () {
    testWidgets('tasks: no skeleton for a fast read, then content', (
      WidgetTester tester,
    ) async {
      final StreamController<List<TaskModel>> controller =
          StreamController<List<TaskModel>>.broadcast();
      addTearDown(controller.close);

      await _pump(
        tester,
        ProviderScope(
          overrides: [
            watchAllTasksProvider.overrideWith((Ref ref) => controller.stream),
          ],
          child: const MaterialApp(home: TasksListScreen()),
        ),
      );

      expect(
        find.byType(TaskRowSkeleton),
        findsNothing,
        reason: 'the gate has not opened yet',
      );
      expect(
        find.byType(VWLoadingIndicator),
        findsNothing,
        reason: 'a spinner is for actions, not for waiting on a shape',
      );

      await tester.pump(_gate);
      expect(find.byType(TaskRowSkeleton), findsWidgets);

      controller.add(<TaskModel>[_task()]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TaskRowSkeleton), findsNothing);
      expect(find.byType(TaskListTile), findsOneWidget);
    });

    testWidgets('finance: no skeleton for a fast read, then content', (
      WidgetTester tester,
    ) async {
      final StreamController<List<TransactionModel>> controller =
          StreamController<List<TransactionModel>>.broadcast();
      addTearDown(controller.close);

      await _pump(
        tester,
        ProviderScope(
          overrides: [
            watchRecentTransactionsProvider.overrideWith(
              (Ref ref, int limit) => controller.stream,
            ),
          ],
          child: const MaterialApp(home: FinanceHomeScreen()),
        ),
      );

      expect(find.byType(TransactionRowSkeleton), findsNothing);

      await tester.pump(_gate);
      expect(find.byType(TransactionRowSkeleton), findsWidgets);

      controller.add(<TransactionModel>[_transaction()]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TransactionRowSkeleton), findsNothing);
      expect(find.byType(TransactionListTile), findsOneWidget);
    });

    testWidgets('notes: no skeleton for a fast read, then content', (
      WidgetTester tester,
    ) async {
      final StreamController<List<NoteModel>> controller =
          StreamController<List<NoteModel>>.broadcast();
      addTearDown(controller.close);

      await _pump(
        tester,
        ProviderScope(
          overrides: [
            watchNotesMatchingProvider.overrideWith(
              (Ref ref, String query) => controller.stream,
            ),
          ],
          child: const MaterialApp(home: NotesListScreen()),
        ),
      );

      expect(find.byType(NoteCardSkeleton), findsNothing);

      await tester.pump(_gate);
      expect(find.byType(NoteCardSkeleton), findsWidgets);

      controller.add(<NoteModel>[_note()]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(NoteCardSkeleton), findsNothing);
      expect(find.byType(NoteListTile), findsOneWidget);
    });

    testWidgets('calendar: no skeleton for a fast read, then content', (
      WidgetTester tester,
    ) async {
      final StreamController<List<CalendarEventModel>> controller =
          StreamController<List<CalendarEventModel>>.broadcast();
      addTearDown(controller.close);

      await _pump(
        tester,
        ProviderScope(
          overrides: [
            watchAllEventsProvider.overrideWith((Ref ref) => controller.stream),
          ],
          child: const MaterialApp(home: CalendarScreen()),
        ),
      );

      expect(find.byType(EventCardSkeleton), findsNothing);

      await tester.pump(_gate);
      expect(find.byType(EventCardSkeleton), findsWidgets);

      controller.add(<CalendarEventModel>[_event()]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EventCardSkeleton), findsNothing);
      expect(find.byType(EventListTile), findsOneWidget);
    });
  });
}
