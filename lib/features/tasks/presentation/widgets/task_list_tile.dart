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
    this.morphing = false,
    super.key,
  });

  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  /// Set while the task-complete morph is playing (plan2.md P9-T4).
  ///
  /// The row is deliberately shown as *completed before the write lands*: the
  /// screen holds the state change back until the animation has finished, so
  /// the morph is visible on the row the user actually touched instead of on
  /// its re-created twin in the "Completed" section.
  final bool morphing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final bool done = task.isCompleted || morphing;
    final int doneCount = task.subTasks.where((SubTask s) => s.isDone).length;

    return ListTile(
      onTap: onTap,
      leading: _TaskCheckbox(
        done: task.isCompleted,
        morphing: morphing,
        onToggle: onToggle,
      ),
      title: AnimatedDefaultTextStyle(
        // Completing a task eases the muted colour in rather than snapping
        // (P5-T1); the strikethrough itself sweeps via _StrikeThroughText.
        duration: motionDuration(context, AppMotion.stateChange),
        curve: AppMotion.standardCurve,
        style: theme.textTheme.bodyLarge!.copyWith(
          color: done ? muted : theme.colorScheme.onSurface,
        ),
        child: _StrikeThroughText(text: task.title, struck: done, color: muted),
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

/// The completion checkbox, with a short "pop" when it fills (P9-T4).
///
/// A stock [Checkbox] underneath, on purpose: it keeps the built-in checked
/// semantics for TalkBack and the 48px tap target. This only adds the scale
/// overshoot on top.
class _TaskCheckbox extends StatefulWidget {
  const _TaskCheckbox({
    required this.done,
    required this.morphing,
    required this.onToggle,
  });

  final bool done;
  final bool morphing;
  final VoidCallback onToggle;

  @override
  State<_TaskCheckbox> createState() => _TaskCheckboxState();
}

class _TaskCheckboxState extends State<_TaskCheckbox>
    with SingleTickerProviderStateMixin {
  // Built in initState rather than with a `late final` initialiser: the lazy
  // form only runs on first access, and under reduced motion the first access
  // would be `dispose()` — creating a ticker on a deactivated element, which
  // trips a framework assertion.
  late final AnimationController _controller;

  /// Out past 1 and back: the little overshoot that makes the tick feel
  /// physical. Driven by `curveEmphasized` on the way out.
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.signature,
      value: 1,
    );
    _scale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 1.18,
        ).chain(CurveTween(curve: AppMotion.curveEmphasized)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.18,
          end: 1,
        ).chain(CurveTween(curve: AppMotion.standardCurve)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _TaskCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only on completion, and only when the morph is actually wanted.
    if (widget.morphing && !oldWidget.morphing) {
      _controller.duration = motionDuration(context, AppMotion.signature);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget checkbox = Checkbox(
      value: widget.done || widget.morphing,
      onChanged: (_) => widget.onToggle(),
    );

    if (prefersReducedMotion(context)) {
      return checkbox;
    }

    return ScaleTransition(scale: _scale, child: checkbox);
  }
}

/// Draws the task's title, sweeping a strikethrough across it when it is
/// completed (P9-T4).
///
/// `TextDecoration.lineThrough` appears all at once; a painted line can grow
/// from the start of the word to the end, which is what makes completion read
/// as an action rather than a restyle. The line is clamped to the text box, so
/// `curveEmphasized`'s overshoot cannot leave a stub sticking out past the last
/// letter.
class _StrikeThroughText extends StatefulWidget {
  const _StrikeThroughText({
    required this.text,
    required this.struck,
    required this.color,
  });

  final String text;
  final bool struck;
  final Color color;

  @override
  State<_StrikeThroughText> createState() => _StrikeThroughTextState();
}

class _StrikeThroughTextState extends State<_StrikeThroughText>
    with SingleTickerProviderStateMixin {
  static const double _strokeWidth = 1.5;

  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.struck ? 1 : 0,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.curveEmphasized,
    );
  }

  @override
  void didUpdateWidget(covariant _StrikeThroughText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.struck == widget.struck) {
      return;
    }
    _controller.duration = motionDuration(
      context,
      // Drawing the line takes the emphasized beat; removing it is cleanup.
      widget.struck ? AppMotion.signature : AppMotion.stateChange,
    );
    if (widget.struck) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return Text(
        widget.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: widget.struck
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      );
    }

    return AnimatedBuilder(
      animation: _progress,
      builder: (BuildContext context, Widget? child) => CustomPaint(
        foregroundPainter: _StrikeThroughPainter(
          progress: _progress.value,
          color: widget.color,
          strokeWidth: _strokeWidth,
        ),
        child: child,
      ),
      child: Text(widget.text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _StrikeThroughPainter extends CustomPainter {
  const _StrikeThroughPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double reach = progress.clamp(0, 1);
    if (reach <= 0 || size.width <= 0) {
      return;
    }

    final double y = size.height * 0.55;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * reach, y),
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_StrikeThroughPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
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
