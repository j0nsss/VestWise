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
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_notification_banner.dart';
import 'package:vestwise/core/widgets/vw_section_header.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_list_tile.dart';

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

  Future<void> _toggleComplete(TaskModel task) async {
    if (_morphingId == task.id) {
      // Already mid-morph: ignore the impatient second tap.
      return;
    }

    // Captured before any await, so the write still lands if the screen is
    // disposed while the animation is running.
    final TasksRepository repository = ref.read(tasksRepositoryProvider);
    final NotificationService notifications =
        ref.read(notificationServiceProvider);

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
    final int? reminderId = task.notificationId;
    if (!task.isCompleted && reminderId != null) {
      try {
        await notifications.cancelNotification(reminderId);
      } catch (_) {
        // The reminder may already have fired; cancelling is best-effort.
      }
      task.notificationId = null;
      await repository.updateTask(task);
    }
    await repository.toggleComplete(task.id);
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
    final AsyncValue<List<TaskModel>> tasksAsync = ref.watch(watchAllTasksProvider);

    return Scaffold(
      appBar: const VWAppBar(title: AppStrings.tasks),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add task',
        onPressed: () => context.go(RoutePaths.taskDetailFor(RoutePaths.newId)),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          const VWNotificationBanner(),
          Expanded(
            child: tasksAsync.when(
              loading: () => const VWLoadingIndicator(),
              error: (Object error, StackTrace stack) => VWEmptyState(
                icon: Icons.error_outline,
                title: 'Could not load your tasks',
                message: 'Something went wrong reading your tasks.',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(watchAllTasksProvider),
              ),
              data: (List<TaskModel> tasks) {
                if (tasks.isEmpty) {
                  return VWEmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'No tasks yet',
                    message: 'No tasks yet — add your first one.',
                    actionLabel: 'Add task',
                    onAction: () =>
                        context.go(RoutePaths.taskDetailFor(RoutePaths.newId)),
                  );
                }

                final List<TaskModel> active =
                    tasks.where((TaskModel t) => !t.isCompleted).toList();
                final List<TaskModel> completed =
                    tasks.where((TaskModel t) => t.isCompleted).toList();

                return CustomScrollView(
                  slivers: <Widget>[
                    if (active.isNotEmpty) ...<Widget>[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                          child: VWSectionHeader(title: 'Active'),
                        ),
                      ),
                      _TaskSliverList(
                        tasks: active,
                        morphingId: _morphingId,
                        onToggle: _toggleComplete,
                      ),
                    ],
                    if (completed.isNotEmpty) ...<Widget>[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                          child: VWSectionHeader(title: 'Completed'),
                        ),
                      ),
                      _TaskSliverList(
                        tasks: completed,
                        morphingId: _morphingId,
                        onToggle: _toggleComplete,
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 88)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskSliverList extends ConsumerWidget {
  const _TaskSliverList({
    required this.tasks,
    required this.morphingId,
    required this.onToggle,
  });

  final List<TaskModel> tasks;
  final int? morphingId;
  final Future<void> Function(TaskModel task) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final TaskModel task = tasks[index];
        final Widget tile = TaskListTile(
          task: task,
          morphing: morphingId == task.id,
          onToggle: () => unawaited(onToggle(task)),
          onTap: () => context.go(RoutePaths.taskDetailFor(task.id)),
        );
        // Keyed by id so a task added at the top mounts fresh (and therefore
        // animates in) while existing rows keep their state and stay still.
        final Key key = ValueKey<int>(task.id);
        return VWAnimatedListItem.animates(index)
            ? VWAnimatedListItem(key: key, child: tile)
            : KeyedSubtree(key: key, child: tile);
      },
    );
  }
}
