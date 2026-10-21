import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_animated_list_item.dart';
import 'package:vestwise/core/widgets/vw_delayed.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_fade_through.dart';
import 'package:vestwise/core/widgets/vw_fab.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';
import 'package:vestwise/core/widgets/vw_section_disclosure.dart';
import 'package:vestwise/core/widgets/vw_screen_header.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';
import 'package:vestwise/core/widgets/vw_notification_banner.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/task_reminders.dart';
import 'package:vestwise/features/tasks/presentation/widgets/delete_task_dialog.dart';
import 'package:vestwise/features/tasks/presentation/widgets/swipeable_task_row.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_groups.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_list_tile.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_row_skeleton.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_quick_add.dart';

/// Task list (plan P3-TASK-1).
///
/// Design choice: completed tasks are *not* filtered out of the stream. They are
/// shown in a separate "Completed" section below the active ones, so the user
/// keeps an at-a-glance sense of progress without losing the data.
class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  /// The task whose completion morph is currently playing (plan2.md P9-T4).
  ///
  /// The write that moves the row into "Completed" is held back until the
  /// animation finishes: the row is re-created in the other section, so if the
  /// state changed immediately the morph would play on a widget the user never
  /// touched — or not at all.
  int? _morphingId;

  /// Which groups the user has collapsed. In-memory only, like the notes list
  /// (plan2.md P10-TASKS-1 / P10-NOTES-3): which groups you folded away is a
  /// glance-level preference, not something to persist.
  final Set<TaskGroup> _collapsed = <TaskGroup>{};

  Future<void> _toggleComplete(TaskModel task) async {
    if (_morphingId == task.id) {
      // Already mid-morph: ignore the impatient second tap.
      return;
    }

    // Captured before any await, so the write still lands if the screen is
    // disposed while the animation is running.
    final TasksRepository repository = ref.read(tasksRepositoryProvider);
    final NotificationService notifications = ref.read(
      notificationServiceProvider,
    );

    unawaited(_haptic());

    final Duration morph = motionDuration(context, AppMotion.signature);
    if (!task.isCompleted && morph > Duration.zero) {
      setState(() => _morphingId = task.id);
      await Future<void>.delayed(morph);
      if (mounted) {
        setState(() => _morphingId = null);
      }
    }

    // Completing a task also cancels its pending reminder (P4-T3).
    if (!task.isCompleted && task.notificationId != null) {
      await cancelTaskReminder(notifications, task.notificationId);
      task.notificationId = null;
      await repository.updateTask(task);
    }
    await repository.toggleComplete(task.id);
  }

  /// Swipe-to-delete (plan P10-TASKS-3): confirm, cancel the reminder, then
  /// delete. The same three steps the detail screen performs, through the same
  /// two helpers — the swipe adds a gesture, not a second delete path.
  Future<void> _deleteTask(TaskModel task) async {
    final bool confirmed = await confirmTaskDeletion(context);
    if (!confirmed || !mounted) {
      return;
    }

    // Captured before any await so the write still lands if the screen is
    // disposed while the dialog closes.
    final TasksRepository repository = ref.read(tasksRepositoryProvider);
    final NotificationService notifications = ref.read(
      notificationServiceProvider,
    );

    await cancelTaskReminder(notifications, task.notificationId);
    await repository.deleteTask(task.id);
  }

  /// A light tick on completion. Best-effort: a device without a haptics engine
  /// must not turn a tap into an error.
  Future<void> _haptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // No haptics engine, or the platform channel is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<TaskModel>> tasksAsync = ref.watch(
      watchAllTasksProvider,
    );

    return Scaffold(
      floatingActionButton: VWFab(
        tooltip: 'Add task',
        onPressed: () => context.go(RoutePaths.taskDetailFor(RoutePaths.newId)),
        child: const Icon(Icons.add),
      ),
      // One comfortable gap over the floating dock (Phase 13).
      floatingActionButtonLocation: const VWFabLocation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            VWScreenHeader(
              title: AppStrings.tasks,
              onCreate: () =>
                  context.go(RoutePaths.taskDetailFor(RoutePaths.newId)),
            ),
            const VWNotificationBanner(),
            // Pinned above the list rather than scrolled with it: adding a task
            // is the screen's primary action, and hiding it behind a scroll
            // would make the FAB the only way back to it.
            const TaskQuickAdd(),
            Expanded(
              // Loading and content cross-fade instead of popping (P11-T2), and
              // the skeleton is held back by VWDelayed so an instant Isar read
              // never shows a placeholder at all.
              child: VWFadeThrough(
                child: tasksAsync.when(
                  loading: () => const VWDelayed(
                    key: ValueKey<String>('tasks-loading'),
                    child: VWSkeletonList(row: TaskRowSkeleton()),
                  ),
                  error: (Object error, StackTrace stack) => VWEmptyState(
                    key: const ValueKey<String>('tasks-error'),
                    icon: Icons.error_outline,
                    title: 'Could not load your tasks',
                    message: 'Something went wrong reading your tasks.',
                    actionLabel: 'Retry',
                    onAction: () => ref.invalidate(watchAllTasksProvider),
                  ),
                  data: (List<TaskModel> tasks) {
                    if (tasks.isEmpty) {
                      return VWEmptyState(
                        key: const ValueKey<String>('tasks-empty'),
                        icon: Icons.check_circle_outline,
                        title: 'No tasks yet',
                        message: 'No tasks yet — add your first one.',
                        actionLabel: 'Add task',
                        onAction: () => context.go(
                          RoutePaths.taskDetailFor(RoutePaths.newId),
                        ),
                      );
                    }

                    final List<TaskRow> rows = buildTaskRows(
                      tasks,
                      collapsed: _collapsed,
                      today: DateTime.now(),
                    );

                    return CustomScrollView(
                      key: const ValueKey<String>('tasks-list'),
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              vwPageMargin,
                              0,
                              vwPageMargin,
                              AppSpacing.md,
                            ),
                            child: _TaskMomentumCard(tasks: tasks),
                          ),
                        ),
                        SliverList.builder(
                          itemCount: rows.length,
                          itemBuilder: (BuildContext context, int index) {
                            final TaskRow row = rows[index];
                            if (row is TaskGroupRow) {
                              return VWSectionDisclosure(
                                key: ValueKey<TaskGroup>(row.group),
                                label: taskGroupLabel(row.group),
                                count: row.count,
                                unit: 'task',
                                expanded: !_collapsed.contains(row.group),
                                onToggle: () => _toggleGroup(row.group),
                              );
                            }
                            final TaskModel task = (row as TaskItemRow).task;
                            return _TaskListTileRow(
                              task: task,
                              index: index,
                              morphingId: _morphingId,
                              onToggle: _toggleComplete,
                              onDelete: _deleteTask,
                            );
                          },
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: vwDockClearance),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleGroup(TaskGroup group) {
    setState(() {
      if (!_collapsed.remove(group)) {
        _collapsed.add(group);
      }
    });
  }
}

/// The amber momentum card the Omotive mockup opens the list with: how much of
/// the backlog is done, over a ring. Counted from the rows on screen — the same
/// list the sections below render, not a second query.
class _TaskMomentumCard extends StatelessWidget {
  const _TaskMomentumCard({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VWTactilePalette palette = vwTactilePalette(
      context,
      VWTactileTone.amber,
    );
    final int total = tasks.length;
    final int done = tasks.where((TaskModel t) => t.isCompleted).length;
    final double ratio = total == 0 ? 0 : done / total;

    return VWTactileCard(
      tone: VWTactileTone.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWTactileKicker(
            label: 'Task momentum',
            ink: palette.ink,
            trailing: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                children: <Widget>[
                  CircularProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    strokeWidth: 3.5,
                    strokeCap: StrokeCap.round,
                    color: palette.ink,
                    backgroundColor: Colors.black.withValues(alpha: 0.12),
                  ),
                  Center(
                    child: Text(
                      '${(ratio * 100).round()}%',
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: palette.ink,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$done of $total tasks completed',
            style: theme.textTheme.headlineMedium!.copyWith(color: palette.ink),
          ),
          const SizedBox(height: AppSpacing.md),
          VWCardShelf(
            leading: Text(
              '${total - done} still open',
              style: theme.textTheme.bodySmall!.copyWith(
                color: palette.softInk,
              ),
            ),
            trailing: VWPill(
              label: 'Plan',
              icon: Icons.view_agenda,
              background: Colors.black.withValues(alpha: 0.10),
              foreground: palette.ink,
              onTap: () =>
                  context.go(RoutePaths.taskDetailFor(RoutePaths.newId)),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single task row, wrapped in the one-shot entrance animation for the first
/// few rows (plan P5-T1 / P9-T2) and keyed by task id so a new task mounts
/// fresh while existing rows stay still.
class _TaskListTileRow extends ConsumerWidget {
  const _TaskListTileRow({
    required this.task,
    required this.index,
    required this.morphingId,
    required this.onToggle,
    required this.onDelete,
  });

  final TaskModel task;
  final int index;
  final int? morphingId;
  final Future<void> Function(TaskModel task) onToggle;
  final Future<void> Function(TaskModel task) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget tile = SwipeableTaskRow(
      taskId: task.id,
      onSwipeComplete: () => unawaited(onToggle(task)),
      onSwipeDelete: () => onDelete(task),
      child: TaskListTile(
        task: task,
        morphing: morphingId == task.id,
        onToggle: () => unawaited(onToggle(task)),
        onTap: () => context.go(RoutePaths.taskDetailFor(task.id)),
      ),
    );

    final Key key = ValueKey<int>(task.id);
    return VWAnimatedListItem.animates(index)
        ? VWAnimatedListItem(key: key, child: tile)
        : KeyedSubtree(key: key, child: tile);
  }
}
