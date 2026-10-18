import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/task_validation.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';

/// A single line above the task list that creates a task on submit
/// (plan P10-TASKS-2).
///
/// No dialog, no sheet: type a title, press enter, keep typing. Everything the
/// quick-add row deliberately does *not* ask for — priority, due date, sub-tasks
/// — is still set afterwards on the detail screen, which remains the only place
/// those fields live.
///
/// The title rule comes from [validateTaskTitle], the same function the detail
/// form uses, so "empty" cannot come to mean two different things.
class TaskQuickAdd extends ConsumerStatefulWidget {
  const TaskQuickAdd({super.key});

  @override
  ConsumerState<TaskQuickAdd> createState() => _TaskQuickAddState();
}

class _TaskQuickAddState extends ConsumerState<TaskQuickAdd> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit(String rawTitle) async {
    if (_saving || validateTaskTitle(rawTitle) != null) {
      // An empty submit is a no-op, not an error: nothing was asked for.
      return;
    }

    setState(() => _saving = true);
    final DateTime now = DateTime.now();
    final TaskModel task = TaskModel()
      ..title = rawTitle.trim()
      ..priority = TaskPriority.medium
      ..createdAt = now;

    try {
      await ref.read(tasksRepositoryProvider).createTask(task);
      if (!mounted) {
        return;
      }
      _controller.clear();
      // Keep the keyboard up so several tasks can be added in a row.
      _focusNode.requestFocus();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: VWTextField(
        controller: _controller,
        focusNode: _focusNode,
        hint: 'Add a task…',
        textInputAction: TextInputAction.done,
        // Compact single row: no floating label, so the row reads as an input
        // line at the top of the list rather than as a form field.
        onFieldSubmitted: (String value) => _submit(value),
      ),
    );
  }
}
