import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_priority_style.dart';

/// One row in the task list: completion checkbox, title, priority dot, optional
/// sub-task progress and due-date chip (plan P3-TASK-1).
class TaskListTile extends StatelessWidget {
  const TaskListTile({
    required this.task,
    required this.onToggle,
    this.onTap,
    super.key,
  });

  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final bool done = task.isCompleted;
    final int doneCount = task.subTasks.where((SubTask s) => s.isDone).length;

    return ListTile(
      onTap: onTap,
      leading: Checkbox(
        value: done,
        onChanged: (_) => onToggle(),
      ),
      title: AnimatedDefaultTextStyle(
        // Completing a task eases the strike-through and muted colour in rather
        // than snapping (P5-T1).
        duration: AppMotion.stateChange,
        curve: AppMotion.standardCurve,
        style: theme.textTheme.bodyLarge!.copyWith(
          decoration: done ? TextDecoration.lineThrough : null,
          color: done ? muted : theme.colorScheme.onSurface,
        ),
        child: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: <Widget>[
          if (task.subTasks.isNotEmpty)
            Text(
              '$doneCount/${task.subTasks.length}',
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: taskPriorityColor(task.priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                taskPriorityLabel(task.priority),
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
            ],
          ),
          if (task.dueDate != null) _DueChip(date: task.dueDate!, isDone: done),
        ],
      ),
    );
  }
}

class _DueChip extends StatelessWidget {
  const _DueChip({required this.date, required this.isDone});

  final DateTime date;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool overdue = !isDone && date.isBefore(DateTime.now());
    final Color color = overdue
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.schedule, size: 12, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          DateFormat.yMMMd().add_Hm().format(date),
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
