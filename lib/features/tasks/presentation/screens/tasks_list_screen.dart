import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_notification_banner.dart';
import 'package:vestwise/core/widgets/vw_section_header.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_list_tile.dart';

/// Task list (plan P3-TASK-1).
///
/// Design choice: completed tasks are *not* filtered out of the stream. They are
/// shown in a separate "Completed" section below the active ones, so the user
/// keeps an at-a-glance sense of progress without losing the data.
class TasksListScreen extends ConsumerWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TaskModel>> tasksAsync = ref.watch(watchAllTasksProvider);

    return Scaffold(
      appBar: const VWAppBar(title: AppStrings.tasks),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RoutePaths.taskDetailFor(RoutePaths.newId)),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          const VWNotificationBanner(),
          Expanded(
            child: tasksAsync.when(
              loading: () => const VWLoadingIndicator(),
              error: (Object error, StackTrace stack) => const VWEmptyState(
                icon: Icons.error_outline,
                message: 'Could not load your tasks. Please try again.',
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
                      _TaskSliverList(tasks: active),
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
                      _TaskSliverList(tasks: completed),
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
  const _TaskSliverList({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final TaskModel task = tasks[index];
        return TaskListTile(
          task: task,
          onToggle: () => unawaited(_toggleComplete(ref, task)),
          onTap: () => context.go(RoutePaths.taskDetailFor(task.id)),
        );
      },
    );
  }

  /// Completing a task also cancels its pending reminder — a finished task must
  /// not still nag the user (P4-T3). Un-completing leaves the reminder gone; the
  /// user re-opens the task to set a new due date.
  Future<void> _toggleComplete(WidgetRef ref, TaskModel task) async {
    final int? reminderId = task.notificationId;
    if (!task.isCompleted && reminderId != null) {
      try {
        await ref.read(notificationServiceProvider).cancelNotification(reminderId);
      } catch (_) {
        // The reminder may already have fired; cancelling is best-effort.
      }
      task.notificationId = null;
      await ref.read(tasksRepositoryProvider).updateTask(task);
    }
    await ref.read(tasksRepositoryProvider).toggleComplete(task.id);
  }
}
