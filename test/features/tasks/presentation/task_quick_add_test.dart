import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:vestwise/features/tasks/domain/task_validation.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/screens/tasks_list_screen.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_quick_add.dart';

/// Stream-backed so the screen sees what the repository was actually asked to
/// write, rather than a fixture that hides the wiring.
class _RecordingTasksRepository implements TasksRepository {
  final List<TaskModel> created = <TaskModel>[];

  /// Broadcast, so a write is not buffered waiting for a listener that may
  /// never arrive (a buffered, unlistened `close()` never completes, which
  /// hangs the teardown rather than the test).
  final StreamController<List<TaskModel>> allTasks =
      StreamController<List<TaskModel>>.broadcast();

  @override
  Stream<List<TaskModel>> watchAllTasks() async* {
    // Mirrors the real repository's `fireImmediately`: a fresh listener sees
    // the current state before any write happens.
    yield List<TaskModel>.of(created);
    yield* allTasks.stream;
  }

  @override
  Stream<List<TaskModel>> watchTasksDueToday() =>
      const Stream<List<TaskModel>>.empty();

  @override
  Future<Result<int>> createTask(TaskModel task) async {
    created.add(task);
    allTasks.add(List<TaskModel>.of(created));

    return Success<int>(created.length);
  }

  @override
  Future<Result<TaskModel>> getTaskById(int id) async =>
      const Error<TaskModel>(DatabaseFailure('unused'));

  @override
  Future<Result<void>> updateTask(TaskModel task) async =>
      const Success<void>(null);

  @override
  Future<Result<void>> deleteTask(int id) async => const Success<void>(null);

  @override
  Future<Result<void>> toggleComplete(int id) async => const Success<void>(null);
}

Future<_RecordingTasksRepository> _pump(
  WidgetTester tester, {
  bool withList = false,
}) async {
  final _RecordingTasksRepository repository = _RecordingTasksRepository();
  addTearDown(() => repository.allTasks.close());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: withList ? const TasksListScreen() : const _QuickAddOnly(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return repository;
}

/// `pumpAndSettle` never returns while a text field holds focus: the caret
/// blinks on a repeating timer, so the frame queue is never empty. Pump a
/// bounded window instead — long enough for the 180ms row entrance.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

class _QuickAddOnly extends StatelessWidget {
  const _QuickAddOnly();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: TaskQuickAdd());
}

void main() {
  test('the quick-add row shares the detail form\'s title rule', () {
    expect(validateTaskTitle(''), 'Title is required');
    expect(validateTaskTitle('   '), 'Title is required');
    expect(validateTaskTitle(null), 'Title is required');
    expect(validateTaskTitle('Buy milk'), isNull);
  });

  group('TaskQuickAdd (P10-TASKS-2)', () {
    testWidgets('enter creates a medium task with no due date', (
      WidgetTester tester,
    ) async {
      final _RecordingTasksRepository repository = await _pump(tester);
      await tester.enterText(find.byType(TextFormField), '  Buy milk  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);

      expect(repository.created, hasLength(1));
      final TaskModel task = repository.created.single;
      expect(task.title, 'Buy milk', reason: 'the title is trimmed');
      expect(task.priority, TaskPriority.medium);
      expect(task.dueDate, isNull);
      expect(task.isCompleted, isFalse);
    });

    testWidgets('an empty submit writes nothing', (
      WidgetTester tester,
    ) async {
      final _RecordingTasksRepository repository = await _pump(tester);

      // Focus the field first: `receiveAction` needs an attached input client,
      // and it never completes if there is none.
      await tester.tap(find.byType(TextFormField));
      await _settle(tester);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);

      expect(repository.created, isEmpty);

      await tester.enterText(find.byType(TextFormField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);

      expect(repository.created, isEmpty, reason: 'whitespace is not a title');
    });

    testWidgets('the field clears and keeps focus for the next task', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextFormField), 'First');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).focusNode
            .hasFocus,
        isTrue,
      );
    });

    testWidgets('a second submit while the first is in flight is ignored', (
      WidgetTester tester,
    ) async {
      final _RecordingTasksRepository repository = await _pump(tester);

      await tester.enterText(find.byType(TextFormField), 'One');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);

      expect(repository.created, hasLength(1));
    });

    testWidgets('the new task lands in the list, in the right group', (
      WidgetTester tester,
    ) async {
      await _pump(tester, withList: true);

      await tester.enterText(find.byType(TextFormField), 'Buy milk');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);

      // A task with no due date belongs under "No due date" — no manual
      // refresh, no invalidate: the row arrives through the stream.
      expect(find.text('No due date · 1'), findsOneWidget);
      expect(find.text('Buy milk'), findsOneWidget);
    });
  });
}
