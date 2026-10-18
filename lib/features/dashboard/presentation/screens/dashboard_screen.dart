import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_section_header.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_priority_style.dart';

/// Dashboard: aggregates the four features into summary cards (plan P3-DASH-2).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardState state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: VWAppBar(
        title: _greeting(context),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go(RoutePaths.settings),
          ),
        ],
      ),
      body: state.isLoading
          ? const VWLoadingIndicator(message: 'Loading your dashboard')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                if (state.failedSections.isNotEmpty) ...<Widget>[
                  _LoadErrorBanner(sections: state.failedSections),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _TodayTasksCard(tasks: state.todayTasks),
                const SizedBox(height: AppSpacing.lg),
                _BalanceSummaryCard(
                  balance: state.balance,
                  weeklyNetChange: state.weeklyNetChange,
                ),
                const SizedBox(height: AppSpacing.lg),
                _UpcomingDeadlinesCard(events: state.upcomingEvents),
                const SizedBox(height: AppSpacing.lg),
                _QuickNotesCard(notes: state.recentNotes),
              ],
            ),
    );
  }

  String _greeting(BuildContext context) {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}

/// Reports feature streams that failed to load, with a retry-all action
/// (P5-T2). Shown instead of pretending the card is merely empty.
class _LoadErrorBanner extends ConsumerWidget {
  const _LoadErrorBanner({required this.sections});

  final Set<DashboardSection> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String label =
        (sections.map(_label).toList()..sort()).join(', ');

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                "Couldn't load: $label",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                  ..invalidate(watchTasksDueTodayProvider)
                  ..invalidate(watchAllTransactionsProvider)
                  ..invalidate(watchUpcomingEventsProvider)
                  ..invalidate(watchAllNotesProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _label(DashboardSection section) => switch (section) {
        DashboardSection.tasks => 'tasks',
        DashboardSection.finance => 'finance',
        DashboardSection.calendar => 'calendar',
        DashboardSection.notes => 'notes',
      };
}

class _TodayTasksCard extends ConsumerWidget {
  const _TodayTasksCard({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TaskModel> shown = tasks.take(3).toList();

    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWSectionHeader(
            title: "Today's tasks",
            actionLabel: 'See all',
            onAction: () => context.go(RoutePaths.tasks),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (shown.isEmpty)
            const VWEmptyState(
              icon: Icons.celebration_outlined,
              message: 'No tasks for today 🎉',
            )
          else
            for (final TaskModel task in shown)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: task.isCompleted,
                onChanged: (_) =>
                    ref.read(tasksRepositoryProvider).toggleComplete(task.id),
                title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                secondary: Icon(
                  Icons.circle,
                  size: 10,
                  color: taskPriorityColor(task.priority),
                ),
              ),
        ],
      ),
    );
  }
}

class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard({
    required this.balance,
    required this.weeklyNetChange,
  });

  final double balance;
  final double weeklyNetChange;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool positive = weeklyNetChange >= 0;
    final Color changeColor = positive
        ? AppColors.incomeFor(theme.brightness)
        : AppColors.expenseFor(theme.brightness);

    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWSectionHeader(
            title: 'Finance',
            actionLabel: 'See all',
            onAction: () => context.go(RoutePaths.finance),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Balance', style: theme.textTheme.bodyMedium),
          Text(
            formatMoney(balance),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This week: ${positive ? '+' : '-'}${formatMoney(weeklyNetChange.abs())}',
            style: theme.textTheme.bodySmall?.copyWith(color: changeColor),
          ),
        ],
      ),
    );
  }
}

class _UpcomingDeadlinesCard extends StatelessWidget {
  const _UpcomingDeadlinesCard({required this.events});

  final List<CalendarEventModel> events;

  @override
  Widget build(BuildContext context) {
    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWSectionHeader(
            title: 'Upcoming',
            actionLabel: 'See all',
            onAction: () => context.go(RoutePaths.calendar),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (events.isEmpty)
            const VWEmptyState(
              icon: Icons.event_available_outlined,
              message: 'Nothing scheduled coming up.',
            )
          else
            for (final CalendarEventModel event in events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: Color(event.colorValue),
                ),
                title: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat.yMMMd().add_Hm().format(event.startDateTime),
                ),
              ),
        ],
      ),
    );
  }
}

class _QuickNotesCard extends StatelessWidget {
  const _QuickNotesCard({required this.notes});

  final List<NoteModel> notes;

  @override
  Widget build(BuildContext context) {
    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWSectionHeader(
            title: 'Recent notes',
            actionLabel: 'See all',
            onAction: () => context.go(RoutePaths.notes),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notes.isEmpty)
            const VWEmptyState(
              icon: Icons.sticky_note_2_outlined,
              message: 'No notes yet.',
            )
          else
            for (final NoteModel note in notes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  note.contentPlainText.trim().isEmpty
                      ? 'Empty note'
                      : note.contentPlainText.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => context.go(RoutePaths.noteEditorFor(note.id)),
              ),
        ],
      ),
    );
  }
}
