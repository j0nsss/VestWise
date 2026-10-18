import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';

import '../../../helpers/isar_test_harness.dart';

TaskModel _task({
  String title = 'Buy milk',
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  bool completed = false,
}) => TaskModel()
  ..title = title
  ..priority = priority
  ..dueDate = dueDate
  ..isCompleted = completed
  ..createdAt = DateTime.now();

void main() {
  late IsarTestHarness harness;
  late TasksRepository repo;

  setUp(() async {
    harness = await IsarTestHarness.create();
    repo = TasksRepositoryImpl(harness.isar);
  });

  tearDown(() => harness.dispose());

  test('createTask returns id and persists the task', () async {
    final Result<int> created = await repo.createTask(_task());

    final int id = created.fold(
      onSuccess: (int value) => value,
      onError: (failure) => fail(failure.message),
    );
    expect(id, greaterThan(0));

    final Result<TaskModel> fetched = await repo.getTaskById(id);
    expect(fetched.dataOrNull?.title, 'Buy milk');
  });

  test('getTaskById for a missing id returns an error', () async {
    final Result<TaskModel> fetched = await repo.getTaskById(999);
    expect(fetched, isA<Error<TaskModel>>());
  });

  test('updateTask persists changes', () async {
    final int id = (await repo.createTask(_task())).dataOrNull!;

    final Result<TaskModel> loaded = await repo.getTaskById(id);
    await repo.updateTask(loaded.dataOrNull!..title = 'Buy bread');

    expect((await repo.getTaskById(id)).dataOrNull?.title, 'Buy bread');
  });

  test('toggleComplete flips isCompleted and sets completedAt', () async {
    final int id = (await repo.createTask(_task())).dataOrNull!;

    await repo.toggleComplete(id);
    final TaskModel done = (await repo.getTaskById(id)).dataOrNull!;
    expect(done.isCompleted, isTrue);
    expect(done.completedAt, isNotNull);

    await repo.toggleComplete(id);
    final TaskModel open = (await repo.getTaskById(id)).dataOrNull!;
    expect(open.isCompleted, isFalse);
    expect(open.completedAt, isNull);
  });

  test('deleteTask removes the task', () async {
    final int id = (await repo.createTask(_task())).dataOrNull!;

    await repo.deleteTask(id);
    expect((await repo.getTaskById(id)), isA<Error<TaskModel>>());
  });

  test('watchAllTasks emits created tasks (incomplete first)', () async {
    await repo.createTask(_task(title: 'Second'));
    await repo.createTask(_task(title: 'First', completed: true));

    final List<TaskModel> tasks = await repo.watchAllTasks().first;
    expect(
      tasks.map((TaskModel t) => t.title),
      containsAll(<String>['First', 'Second']),
    );
    expect(tasks.first.isCompleted, isFalse);
  });

  test('watchTasksDueToday returns only incomplete tasks due today', () async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day, 9);
    await repo.createTask(_task(title: 'Today', dueDate: today));
    await repo.createTask(
      _task(title: 'Done today', dueDate: today, completed: true),
    );
    await repo.createTask(
      _task(title: 'Tomorrow', dueDate: today.add(const Duration(days: 1))),
    );
    await repo.createTask(_task(title: 'No date'));

    final List<TaskModel> due = await repo.watchTasksDueToday().first;
    expect(due.map((TaskModel t) => t.title), <String>['Today']);
  });
}
