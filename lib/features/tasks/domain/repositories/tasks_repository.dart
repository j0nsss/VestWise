import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';

/// Data-access boundary for tasks (plan P2-T2). Implemented in the data layer;
/// the UI depends only on this interface.
abstract interface class TasksRepository {
  Stream<List<TaskModel>> watchAllTasks();

  Stream<List<TaskModel>> watchTasksDueToday();

  Future<Result<TaskModel>> getTaskById(int id);

  Future<Result<int>> createTask(TaskModel task);

  Future<Result<void>> updateTask(TaskModel task);

  Future<Result<void>> deleteTask(int id);

  Future<Result<void>> toggleComplete(int id);
}
