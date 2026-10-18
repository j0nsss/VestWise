import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_groups.dart';

TaskModel _task(int id, {DateTime? dueDate, bool completed = false}) =>
    TaskModel()
      ..id = id
      ..title = 'Task $id'
      ..priority = TaskPriority.medium
      ..dueDate = dueDate
      ..isCompleted = completed
      ..createdAt = DateTime(2026, 3, 1);

void main() {
  final DateTime today = DateTime(2026, 3, 10, 9);

  group('taskGroupOf', () {
    test('sends unscheduled work to No due date', () {
      expect(taskGroupOf(_task(1), today: today), TaskGroup.noDueDate);
    });

    test('treats a task due today as today', () {
      expect(
        taskGroupOf(_task(1, dueDate: DateTime(2026, 3, 10, 23)), today: today),
        TaskGroup.today,
      );
    });

    test('treats an overdue task as today, not upcoming', () {
      expect(
        taskGroupOf(_task(1, dueDate: DateTime(2026, 3, 1)), today: today),
        TaskGroup.today,
      );
    });

    test('treats tomorrow as upcoming', () {
      expect(
        taskGroupOf(_task(1, dueDate: DateTime(2026, 3, 11)), today: today),
        TaskGroup.upcoming,
      );
    });

    test('completion wins over a due date', () {
      expect(
        taskGroupOf(
          _task(1, dueDate: DateTime(2026, 3, 10), completed: true),
          today: today,
        ),
        TaskGroup.completed,
      );
    });

    test('a task due late tonight still counts as today', () {
      // Guards the boundary: the day ends at midnight, not at the current time.
      expect(
        taskGroupOf(
          _task(1, dueDate: DateTime(2026, 3, 10, 23, 59)),
          today: today,
        ),
        TaskGroup.today,
      );
    });
  });

  group('buildTaskRows', () {
    test('every task appears exactly once, whatever its group', () {
      final List<TaskModel> tasks = <TaskModel>[
        _task(1, dueDate: DateTime(2026, 3, 10)),
        _task(2, dueDate: DateTime(2026, 3, 12)),
        _task(3),
        _task(4, dueDate: DateTime(2026, 2, 1)),
        _task(5, completed: true),
      ];

      final List<TaskRow> rows = buildTaskRows(
        tasks,
        collapsed: <TaskGroup>{},
        today: today,
      );
      final List<int> ids = rows
          .whereType<TaskItemRow>()
          .map((TaskItemRow row) => row.task.id)
          .toList();

      expect(ids, hasLength(tasks.length));
      expect(ids.toSet(), <int>{1, 2, 3, 4, 5});
    });

    test(
      'groups come out in Today, Upcoming, No due date, Completed order',
      () {
        final List<TaskRow> rows = buildTaskRows(
          <TaskModel>[
            _task(1, completed: true),
            _task(2),
            _task(3, dueDate: DateTime(2026, 3, 20)),
            _task(4, dueDate: DateTime(2026, 3, 10)),
          ],
          collapsed: <TaskGroup>{},
          today: today,
        );

        expect(
          rows.whereType<TaskGroupRow>().map((TaskGroupRow row) => row.group),
          <TaskGroup>[
            TaskGroup.today,
            TaskGroup.upcoming,
            TaskGroup.noDueDate,
            TaskGroup.completed,
          ],
        );
      },
    );

    test('empty groups get no heading at all', () {
      final List<TaskRow> rows = buildTaskRows(
        <TaskModel>[_task(1)],
        collapsed: <TaskGroup>{},
        today: today,
      );

      expect(rows, hasLength(2));
      expect((rows.first as TaskGroupRow).group, TaskGroup.noDueDate);
      expect((rows.first as TaskGroupRow).count, 1);
    });

    test('a collapsed group keeps its heading and its count', () {
      final List<TaskRow> rows = buildTaskRows(
        <TaskModel>[
          _task(1, dueDate: DateTime(2026, 3, 10)),
          _task(2, dueDate: DateTime(2026, 3, 10)),
        ],
        collapsed: <TaskGroup>{TaskGroup.today},
        today: today,
      );

      expect(rows, hasLength(1));
      expect((rows.single as TaskGroupRow).count, 2);
    });

    test('order inside a group is the order it arrived in', () {
      final List<TaskModel> tasks = <TaskModel>[
        _task(7, dueDate: DateTime(2026, 3, 10)),
        _task(3, dueDate: DateTime(2026, 3, 10)),
      ];

      final List<TaskRow> rows = buildTaskRows(
        tasks,
        collapsed: <TaskGroup>{},
        today: today,
      );

      expect(
        rows.whereType<TaskItemRow>().map((TaskItemRow row) => row.task.id),
        <int>[7, 3],
      );
    });
  });

  test('group labels read as plain English', () {
    expect(TaskGroup.values.map(taskGroupLabel), <String>[
      'Today',
      'Upcoming',
      'No due date',
      'Completed',
    ]);
  });
}
