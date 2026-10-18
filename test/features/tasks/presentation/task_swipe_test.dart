import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/screens/tasks_list_screen.dart';

import '../../../helpers/notification_service_spy.dart';

TaskModel _task({int id = 7, int? notificationId}) {
  final TaskModel task = TaskModel()
    ..id = id
    ..title = 'Write report'
    ..priority = TaskPriority.medium
    ..createdAt = DateTime(2026, 3, 1);
  task.notificationId = notificationId;

  return task;
}

class _RecordingTasksRepository implements TasksRepository {
  final List<int> toggled = <int>[];
  final List<int> deleted = <int>[];

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
  Future<Result<int>> createTask(TaskModel task) async => const Success<int>(1);

  @override
  Future<Result<void>> updateTask(TaskModel task) async =>
      const Success<void>(null);

  @override
  Future<Result<void>> deleteTask(int id) async {
    deleted.add(id);

    return const Success<void>(null);
  }

  @override
  Future<Result<void>> toggleComplete(int id) async {
    toggled.add(id);

    return const Success<void>(null);
  }
}

Future<_RecordingTasksRepository> _pumpScreen(
  WidgetTester tester, {
  required TaskModel task,
  NotificationServiceSpy? notifications,
}) async {
  final _RecordingTasksRepository repository = _RecordingTasksRepository();
  notifications ??= NotificationServiceSpy();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(repository),
        notificationServiceProvider.overrideWithValue(notifications),
        watchAllTasksProvider.overrideWith(
          (Ref ref) => Stream<List<TaskModel>>.value(<TaskModel>[task]),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const TasksListScreen()),
    ),
  );
  await tester.pumpAndSettle();

  return repository;
}

void main() {
  group('swipe actions (P10-TASKS-3)', () {
    testWidgets('swiping towards the end completes the task', (
      WidgetTester tester,
    ) async {
      final _RecordingTasksRepository repository = await _pumpScreen(
        tester,
        task: _task(),
      );

      await tester.drag(find.text('Write report'), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(repository.toggled, <int>[7]);
      expect(repository.deleted, isEmpty);
      // The row is still there: removal is the stream's job, and the morph is
      // still playing.
      expect(find.text('Write report'), findsOneWidget);
    });

    testWidgets('swiping towards the start asks before destroying anything', (
      WidgetTester tester,
    ) async {
      final _RecordingTasksRepository repository = await _pumpScreen(
        tester,
        task: _task(notificationId: 55),
      );

      await tester.drag(find.text('Write report'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Delete task?'), findsOneWidget);
      expect(
        repository.deleted,
        isEmpty,
        reason: 'the task survives until the user confirms',
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.deleted, isEmpty);
      expect(find.text('Write report'), findsOneWidget);
    });

    testWidgets('confirming the swipe deletes and cancels the reminder', (
      WidgetTester tester,
    ) async {
      final NotificationServiceSpy notifications = NotificationServiceSpy();
      final _RecordingTasksRepository repository = await _pumpScreen(
        tester,
        task: _task(notificationId: 55),
        notifications: notifications,
      );

      await tester.drag(find.text('Write report'), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(notifications.cancelled, <int>[55]);
      expect(repository.deleted, <int>[7]);
    });

    testWidgets('a task with no reminder deletes without a cancel call', (
      WidgetTester tester,
    ) async {
      final NotificationServiceSpy notifications = NotificationServiceSpy();
      final _RecordingTasksRepository repository = await _pumpScreen(
        tester,
        task: _task(),
        notifications: notifications,
      );

      await tester.drag(find.text('Write report'), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(notifications.cancelled, isEmpty);
      expect(repository.deleted, <int>[7]);
    });

    testWidgets('a cancelled delete does not cancel the reminder', (
      WidgetTester tester,
    ) async {
      final NotificationServiceSpy notifications = NotificationServiceSpy();
      await _pumpScreen(
        tester,
        task: _task(notificationId: 55),
        notifications: notifications,
      );

      await tester.drag(find.text('Write report'), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(notifications.cancelled, isEmpty);
    });
  });
}
