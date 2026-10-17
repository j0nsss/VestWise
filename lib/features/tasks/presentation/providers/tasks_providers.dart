import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';

part 'tasks_providers.g.dart';

@riverpod
TasksRepository tasksRepository(Ref ref) {
  return TasksRepositoryImpl(ref.watch(isarProvider).requireValue);
}

@riverpod
Stream<List<TaskModel>> watchAllTasks(Ref ref) =>
    ref.watch(tasksRepositoryProvider).watchAllTasks();

@riverpod
Stream<List<TaskModel>> watchTasksDueToday(Ref ref) =>
    ref.watch(tasksRepositoryProvider).watchTasksDueToday();
