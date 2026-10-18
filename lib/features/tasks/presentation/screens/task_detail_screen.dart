import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/notifications/inexact_alarm_notice.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/task_validation.dart';
import 'package:vestwise/features/tasks/presentation/task_reminders.dart';
import 'package:vestwise/features/tasks/presentation/widgets/delete_task_dialog.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_priority_style.dart';

/// Task create/edit form with an embedded sub-task checklist (plan P3-TASK-2).
/// `':id' == 'new'` opens the create flow.
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String? taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  final List<_SubTaskField> _subTasks = <_SubTaskField>[];

  int? _taskId;
  int? _notificationId;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => _taskId != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final String? raw = widget.taskId;
    final int? id = raw == null ? null : int.tryParse(raw);
    if (id == null || raw == RoutePaths.newId) {
      setState(() => _loading = false);
      return;
    }

    final TaskModel? task =
        (await ref.read(tasksRepositoryProvider).getTaskById(id)).dataOrNull;
    if (task != null) {
      _taskId = task.id;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
      _notificationId = task.notificationId;
      _subTasks
        ..clear()
        ..addAll(task.subTasks.map((SubTask s) => _SubTaskField(subTask: s)));
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final _SubTaskField field in _subTasks) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWAppBar(
        title: _isEditing ? 'Edit task' : 'New task',
        actions: <Widget>[
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete task',
              onPressed: _loading ? null : _confirmDelete,
            ),
        ],
      ),
      body: _loading
          ? const VWLoadingIndicator()
          : Form(key: _formKey, child: _buildForm(context)),
    );
  }

  Widget _buildForm(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        VWTextField(
          controller: _titleController,
          label: 'Title',
          textInputAction: TextInputAction.next,
          validator: validateTaskTitle,
        ),
        const SizedBox(height: AppSpacing.lg),
        VWTextField(
          controller: _descriptionController,
          label: 'Description',
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Priority', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<TaskPriority>(
          segments: TaskPriority.values
              .map(
                (TaskPriority p) => ButtonSegment<TaskPriority>(
                  value: p,
                  label: Text(taskPriorityLabel(p)),
                ),
              )
              .toList(),
          selected: <TaskPriority>{_priority},
          onSelectionChanged: (Set<TaskPriority> selection) =>
              setState(() => _priority = selection.first),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Due date', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(
                  _dueDate == null
                      ? 'Set due date'
                      : DateFormat.yMMMd().add_Hm().format(_dueDate!),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _pickDueDate,
              ),
            ),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear due date',
                onPressed: () => setState(() => _dueDate = null),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Sub-tasks', style: theme.textTheme.titleSmall),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              onPressed: _addSubTask,
            ),
          ],
        ),
        _buildSubTaskList(),
        const SizedBox(height: AppSpacing.xxl),
        VWButton(
          label: _isEditing ? 'Save changes' : 'Create task',
          expand: true,
          isLoading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }

  Widget _buildSubTaskList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _subTasks.length,
      onReorderItem: _reorder,
      itemBuilder: (BuildContext context, int index) {
        final _SubTaskField field = _subTasks[index];
        return Row(
          key: ValueKey<String>(field.localId),
          children: <Widget>[
            Checkbox(
              value: field.isDone,
              onChanged: (bool? value) =>
                  setState(() => field.isDone = value ?? false),
            ),
            Expanded(
              child: TextFormField(
                controller: field.title,
                decoration: const InputDecoration(hintText: 'Sub-task'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove sub-task',
              onPressed: () => _removeSubTask(field),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addSubTask() {
    setState(() => _subTasks.add(_SubTaskField()));
  }

  void _removeSubTask(_SubTaskField field) {
    setState(() => _subTasks.remove(field));
    field.dispose();
  }

  void _reorder(int oldIndex, int newIndex) {
    // `onReorderItem` already normalises newIndex for the removed item.
    setState(() {
      final _SubTaskField field = _subTasks.removeAt(oldIndex);
      _subTasks.insert(newIndex, field);
    });
  }

  Future<void> _pickDueDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) {
      return;
    }
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? now),
    );
    if (time == null || !mounted) {
      return;
    }
    setState(() {
      _dueDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);

    final NotificationService notifications =
        ref.read(notificationServiceProvider);
    final DateTime now = DateTime.now();
    final List<SubTask> subTasks = _subTasks
        .map((_SubTaskField f) => f.toSubTask())
        .where((SubTask s) => s.title.isNotEmpty)
        .toList();

    // Cancel any reminder scheduled on a previous save before re-scheduling, so
    // editing the due date never leaves a stale notification behind (P4-T3).
    if (_notificationId != null) {
      await cancelTaskReminder(notifications, _notificationId);
    }

    int? notificationId;
    final DateTime? due = _dueDate;
    if (due != null && due.isAfter(now)) {
      final ScheduledReminder? reminder = await _safeSchedule(
        notifications,
        title: _titleController.text.trim(),
        due: due,
      );
      notificationId = reminder?.id;
      if (reminder != null && !reminder.isExact && mounted) {
        await maybeShowInexactAlarmNotice(context, notifications);
      }
    }

    final String description = _descriptionController.text.trim();
    final TaskModel task = TaskModel()
      ..title = _titleController.text.trim()
      ..description = description.isEmpty ? null : description
      ..priority = _priority
      ..dueDate = due
      ..subTasks = subTasks
      ..notificationId = notificationId
      ..createdAt = now;

    if (_isEditing) {
      final TaskModel? existing =
          (await ref.read(tasksRepositoryProvider).getTaskById(_taskId!))
              .dataOrNull;
      if (existing != null) {
        task
          ..id = existing.id
          ..isCompleted = existing.isCompleted
          ..completedAt = existing.completedAt
          ..createdAt = existing.createdAt;
      }
      final result =
          await ref.read(tasksRepositoryProvider).updateTask(task);
      if (!mounted) {
        return;
      }
      result.fold(
        onSuccess: (_) => context.pop(),
        onError: (Failure f) => _onSaveFailed(f),
      );
    } else {
      final result =
          await ref.read(tasksRepositoryProvider).createTask(task);
      if (!mounted) {
        return;
      }
      result.fold(
        onSuccess: (_) => context.pop(),
        onError: (Failure f) => _onSaveFailed(f),
      );
    }
  }

  void _onSaveFailed(Failure failure) {
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(failure.message)));
  }

  Future<void> _confirmDelete() async {
    final bool confirmed = await confirmTaskDeletion(context);
    if (!confirmed || !mounted) {
      return;
    }

    await cancelTaskReminder(
      ref.read(notificationServiceProvider),
      _notificationId,
    );
    await ref.read(tasksRepositoryProvider).deleteTask(_taskId!);
    if (mounted) {
      context.pop();
    }
  }

  Future<ScheduledReminder?> _safeSchedule(
    NotificationService service, {
    required String title,
    required DateTime due,
  }) async {
    try {
      await service.requestPermissions();
      return await service.scheduleReminder(
        title: title.isEmpty ? 'Task reminder' : title,
        body: "It's due now.",
        scheduledDate: due,
      );
    } catch (_) {
      return null;
    }
  }

}

/// A single editable sub-task row: its completion state, text controller and a
/// stable [localId] so reordering keeps widget state attached to the right row.
class _SubTaskField {
  _SubTaskField({SubTask? subTask})
      : isDone = subTask?.isDone ?? false,
        localId = subTask?.localId ?? const Uuid().v4(),
        title = TextEditingController(text: subTask?.title ?? '');

  final String localId;
  bool isDone;
  final TextEditingController title;

  SubTask toSubTask() => SubTask()
    ..localId = localId
    ..title = title.text.trim()
    ..isDone = isDone;

  void dispose() => title.dispose();
}
