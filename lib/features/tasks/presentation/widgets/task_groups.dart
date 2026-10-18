import 'package:vestwise/features/tasks/data/models/task_model.dart';

/// The four groups the task list is split into (plan P10-TASKS-1).
enum TaskGroup { today, upcoming, noDueDate, completed }

/// One row of the task list: either a group heading or a task.
///
/// Flattened to a row script so the list stays a single lazy sliver
/// (plan P5-T5) and collapsing a group is just a shorter script.
sealed class TaskRow {
  const TaskRow();
}

class TaskGroupRow extends TaskRow {
  const TaskGroupRow(this.group, this.count);

  final TaskGroup group;
  final int count;
}

class TaskItemRow extends TaskRow {
  const TaskItemRow(this.task);

  final TaskModel task;
}

String taskGroupLabel(TaskGroup group) => switch (group) {
  TaskGroup.today => 'Today',
  TaskGroup.upcoming => 'Upcoming',
  TaskGroup.noDueDate => 'No due date',
  TaskGroup.completed => 'Completed',
};

/// Which group a task belongs to. Total by construction: every task lands in
/// exactly one group, which is what keeps P10-TASKS-1's "no task silently
/// hidden" promise true.
///
/// Overdue tasks are folded into [TaskGroup.today]. A separate "Overdue" group
/// was not asked for, and the alternative — putting them under "Upcoming" —
/// would be a lie about a date that has already passed.
TaskGroup taskGroupOf(TaskModel task, {required DateTime today}) {
  if (task.isCompleted) {
    return TaskGroup.completed;
  }
  final DateTime? due = task.dueDate;
  if (due == null) {
    return TaskGroup.noDueDate;
  }
  final DateTime endOfToday = DateTime(
    today.year,
    today.month,
    today.day,
  ).add(const Duration(days: 1));
  return due.isBefore(endOfToday) ? TaskGroup.today : TaskGroup.upcoming;
}

/// Lays [tasks] out as rows, honouring [collapsed].
///
/// [today] is injected rather than read from the clock so the grouping is
/// testable at any date, including around midnight.
///
/// Within a group the incoming order is preserved: the repository already sorts
/// by completion, then due date, then newest first, and re-sorting here would
/// be a second source of truth. Empty groups are not rendered at all — a
/// heading over nothing is noise, and the count would say 0 anyway.
List<TaskRow> buildTaskRows(
  List<TaskModel> tasks, {
  required Set<TaskGroup> collapsed,
  required DateTime today,
}) {
  final Map<TaskGroup, List<TaskModel>> grouped = <TaskGroup, List<TaskModel>>{
    for (final TaskGroup group in TaskGroup.values) group: <TaskModel>[],
  };
  for (final TaskModel task in tasks) {
    grouped[taskGroupOf(task, today: today)]!.add(task);
  }

  final List<TaskRow> rows = <TaskRow>[];
  for (final TaskGroup group in TaskGroup.values) {
    final List<TaskModel> groupTasks = grouped[group]!;
    if (groupTasks.isEmpty) {
      continue;
    }
    rows.add(TaskGroupRow(group, groupTasks.length));
    if (!collapsed.contains(group)) {
      rows.addAll(<TaskRow>[
        for (final TaskModel task in groupTasks) TaskItemRow(task),
      ]);
    }
  }

  return rows;
}
