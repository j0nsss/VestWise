import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_section_disclosure.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/screens/tasks_list_screen.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_list_tile.dart';

TaskModel _task({
  int id = 0,
  String title = 'Buy milk',
  bool completed = false,
  DateTime? dueDate,
}) {
  final TaskModel task = TaskModel()
    ..id = id
    ..title = title
    ..priority = TaskPriority.medium
    ..isCompleted = completed
    ..createdAt = DateTime(2026, 1, 1);

  task.dueDate = dueDate;

  return task;
}

class _FakeTasksRepository implements TasksRepository {
  final List<int> toggled = <int>[];
  final List<int> updated = <int>[];

  @override
  Stream<List<TaskModel>> watchAllTasks() =>
      const Stream<List<TaskModel>>.empty();

  @override
  Stream<List<TaskModel>> watchTasksDueToday() =>
      const Stream<List<TaskModel>>.empty();

  @override
  Future<Result<TaskModel>> getTaskById(int id) async =>
      const Error<TaskModel>(DatabaseFailure('unused'));

  @override
  Future<Result<int>> createTask(TaskModel task) async => const Success<int>(0);

  @override
  Future<Result<void>> updateTask(TaskModel task) async {
    updated.add(task.id);

    return const Success<void>(null);
  }

  @override
  Future<Result<void>> deleteTask(int id) async => const Success<void>(null);

  @override
  Future<Result<void>> toggleComplete(int id) async {
    toggled.add(id);

    return const Success<void>(null);
  }
}

Widget _wrap(Widget child, {bool reduce = false}) => MaterialApp(
  theme: AppTheme.light,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: child,
  ),
);

void main() {
  group('TaskListTile (P9-T4)', () {
    testWidgets('toggles through the checkbox', (WidgetTester tester) async {
      int toggles = 0;
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: TaskListTile(task: _task(), onToggle: () => toggles++),
          ),
        ),
      );

      expect(find.text('Buy milk'), findsOneWidget);
      // Phase 13 restyle renders the priority as an uppercase micro-tag.
      expect(find.text('MEDIUM'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      expect(toggles, 1);
    });

    testWidgets('shows a completed task as checked and struck through', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: TaskListTile(task: _task(completed: true), onToggle: () {}),
          ),
        ),
      );

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('morphing shows the tick before the write has landed', (
      WidgetTester tester,
    ) async {
      // The screen holds the write back for the length of the morph, so the row
      // has to *look* completed while `isCompleted` is still false.
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: TaskListTile(task: _task(), morphing: true, onToggle: () {}),
          ),
        ),
      );

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('a completed task paints the strikethrough line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: TaskListTile(task: _task(completed: true), onToggle: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bool painted = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .any((CustomPaint paint) => paint.foregroundPainter != null);
      expect(painted, isTrue);
    });

    testWidgets('reduced motion uses the plain decoration instead', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: TaskListTile(task: _task(completed: true), onToggle: () {}),
          ),
          reduce: true,
        ),
      );

      final Text title = tester.widget<Text>(find.text('Buy milk'));
      expect(title.style?.decoration, TextDecoration.lineThrough);
    });
  });

  group('task completion orchestration (P9-T4)', () {
    Future<_FakeTasksRepository> pumpScreen(
      WidgetTester tester, {
      bool reduce = false,
    }) async {
      final _FakeTasksRepository repository = _FakeTasksRepository();
      final TaskModel task = _task(id: 7, title: 'Write report');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAllTasksProvider.overrideWith(
              (Ref ref) => Stream<List<TaskModel>>.value(<TaskModel>[task]),
            ),
            tasksRepositoryProvider.overrideWithValue(repository),
          ],
          child: _wrap(const TasksListScreen(), reduce: reduce),
        ),
      );
      await tester.pumpAndSettle();

      return repository;
    }

    testWidgets('holds the write back until the morph has played', (
      WidgetTester tester,
    ) async {
      final _FakeTasksRepository repository = await pumpScreen(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        repository.toggled,
        isEmpty,
        reason: 'the row must not move to Completed mid-morph',
      );

      await tester.pumpAndSettle();
      expect(repository.toggled, <int>[7]);
    });

    testWidgets('the morph lasts exactly the signature beat', (
      WidgetTester tester,
    ) async {
      final _FakeTasksRepository repository = await pumpScreen(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.pump(AppMotion.signature - const Duration(milliseconds: 50));
      expect(repository.toggled, isEmpty);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(repository.toggled, <int>[7]);
    });

    testWidgets('reduced motion writes immediately, with no morph', (
      WidgetTester tester,
    ) async {
      final _FakeTasksRepository repository = await pumpScreen(
        tester,
        reduce: true,
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(repository.toggled, <int>[7]);

      await tester.pumpAndSettle();
    });

    testWidgets('a second tap during the morph is ignored', (
      WidgetTester tester,
    ) async {
      final _FakeTasksRepository repository = await pumpScreen(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(repository.toggled, <int>[7]);
    });
  });

  group('task list grouping (P10-TASKS-1)', () {
    Future<void> pumpGroups(
      WidgetTester tester,
      List<TaskModel> tasks, {
      bool reduce = false,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAllTasksProvider.overrideWith(
              (Ref ref) => Stream<List<TaskModel>>.value(tasks),
            ),
            tasksRepositoryProvider.overrideWithValue(_FakeTasksRepository()),
          ],
          child: _wrap(const TasksListScreen(), reduce: reduce),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('every task lands in exactly one group', (
      WidgetTester tester,
    ) async {
      await pumpGroups(tester, <TaskModel>[
        _task(id: 1, title: 'Due today', dueDate: DateTime.now()),
        _task(
          id: 2,
          title: 'Due later',
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
        _task(id: 3, title: 'No date'),
        _task(id: 4, title: 'Done', completed: true),
      ]);

      expect(find.text('Today · 1'), findsOneWidget);
      expect(find.text('Upcoming · 1'), findsOneWidget);
      expect(find.text('No due date · 1'), findsOneWidget);
      // Nothing is hidden behind a group heading.
      for (final String title in <String>['Due today', 'Due later', 'No date']) {
        expect(find.text(title), findsOneWidget);
      }

      // Phase 14 puts the momentum card above the groups, so the tail of the
      // list starts below the fold — the sliver builds lazily, so scroll the
      // last group in before asserting it.
      await tester.drag(
        find.byKey(const ValueKey<String>('tasks-list')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(find.text('Completed · 1'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('groups collapse and re-open on tap, independently', (
      WidgetTester tester,
    ) async {
      await pumpGroups(tester, <TaskModel>[
        _task(id: 1, title: 'Due today', dueDate: DateTime.now()),
        _task(id: 3, title: 'No date'),
      ]);

      await tester.tap(find.text('Today · 1'));
      await tester.pumpAndSettle();

      expect(find.text('Due today'), findsNothing);
      expect(find.text('No date'), findsOneWidget);
      expect(find.text('Today · 1'), findsOneWidget);

      await tester.tap(find.text('No due date · 1'));
      await tester.pumpAndSettle();
      expect(find.text('No date'), findsNothing);

      await tester.tap(find.text('Today · 1'));
      await tester.pumpAndSettle();
      expect(find.text('Due today'), findsOneWidget);
    });

    testWidgets('an empty group gets no heading', (WidgetTester tester) async {
      await pumpGroups(tester, <TaskModel>[_task(id: 3, title: 'No date')]);

      expect(find.byType(VWSectionDisclosure), findsOneWidget);
      expect(find.text('No due date · 1'), findsOneWidget);
      expect(find.text('Today · 0'), findsNothing);
    });

    testWidgets('the headings are announced with their state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpGroups(tester, <TaskModel>[
        _task(id: 1, title: 'Due today', dueDate: DateTime.now()),
        _task(id: 3, title: 'No date'),
      ]);

      expect(
        tester.getSemantics(find.text('Today · 1')),
        isSemantics(label: 'Today, 1 task', isButton: true, isExpanded: true),
      );
      handle.dispose();
    });
  });
}
