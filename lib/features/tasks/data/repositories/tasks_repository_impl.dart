import 'package:isar_community/isar.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/errors/result_guard.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._isar);

  final Isar _isar;

  IsarCollection<TaskModel> get _tasks => _isar.taskModels;

  @override
  Stream<List<TaskModel>> watchAllTasks() => _tasks
      .where()
      .sortByIsCompleted()
      .thenByDueDate()
      .thenByCreatedAtDesc()
      .watch(fireImmediately: true);

  @override
  Stream<List<TaskModel>> watchTasksDueToday() {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month, now.day);
    final DateTime end = start.add(const Duration(days: 1));
    return _tasks
        .filter()
        .isCompletedEqualTo(false)
        .dueDateBetween(start, end)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  @override
  Future<Result<TaskModel>> getTaskById(int id) => resultGuard(
        () async {
          final TaskModel? task = await _tasks.get(id);
          if (task == null) {
            throw StateError('Task $id not found');
          }
          return task;
        },
        operation: 'getTaskById',
      );

  @override
  Future<Result<int>> createTask(TaskModel task) => resultGuard(
        () async {
          await _isar.writeTxn(() async {
            task.id = await _tasks.put(task);
          });
          return task.id;
        },
        operation: 'createTask',
      );

  @override
  Future<Result<void>> updateTask(TaskModel task) => resultGuard(
        () async {
          await _isar.writeTxn(() => _tasks.put(task));
        },
        operation: 'updateTask',
      );

  @override
  Future<Result<void>> deleteTask(int id) => resultGuard(
        () async {
          await _isar.writeTxn(() => _tasks.delete(id));
        },
        operation: 'deleteTask',
      );

  @override
  Future<Result<void>> toggleComplete(int id) => resultGuard(
        () async {
          await _isar.writeTxn(() async {
            final TaskModel? task = await _tasks.get(id);
            if (task == null) {
              throw StateError('Task $id not found');
            }
            task.isCompleted = !task.isCompleted;
            task.completedAt = task.isCompleted ? DateTime.now() : null;
            await _tasks.put(task);
          });
        },
        operation: 'toggleComplete',
      );
}
