import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';
import 'package:vestwise/core/widgets/vw_screen_header.dart';
import 'package:vestwise/core/widgets/vw_sparkline.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:vestwise/features/finance/domain/models/daily_net.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_priority_style.dart';

/// Dashboard, restyled Phase 14 per the "Omotive Style" mockup: the header's
/// Create pill, a week capsule strip, then the tactile card run — pistachio
/// balance hero, amber task momentum, the coral urgent card when something is
/// actually urgent, two bento tiles and the schedule/notes snapshots.
///
/// The mockup's decorative orb stack is gone: Omotive has no glow. Everything
/// on this screen is a figure or a record the app really holds (P5-T2's honest
/// -UI rule) — no "8.4% momentum" or "Q2 sprint" copy is invented.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardState state = ref.watch(dashboardProvider);
    final TaskModel? urgentTask = _urgentOf(state.todayTasks);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: state.isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  vwPageMargin,
                  0,
                  vwPageMargin,
                  vwDockClearance,
                ),
                children: <Widget>[
                  VWScreenHeader(
                    title: 'Dashboard',
                    onCreate: () => context.go(RoutePaths.financeAdd),
                  ),
                  _WeekCapsuleStrip(),
                  const SizedBox(height: AppSpacing.lg),
                  const _OverviewHeading(),
                  const SizedBox(height: AppSpacing.md),
                  if (state.failedSections.isNotEmpty) ...<Widget>[
                    _LoadErrorBanner(sections: state.failedSections),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _BalanceSummaryCard(
                    balance: state.balance,
                    weeklyNetChange: state.weeklyNetChange,
                    last7DaysNet: state.last7DaysNet,
                    hasData: state.hasFinanceData,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FocusCard(tasks: state.todayTasks),
                  if (urgentTask != null ||
                      state.upcomingEvents.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    _UrgentCard(
                      task: urgentTask,
                      event: urgentTask != null || state.upcomingEvents.isEmpty
                          ? null
                          : state.upcomingEvents.first,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _StatTiles(
                    last7DaysNet: state.last7DaysNet,
                    tasks: state.todayTasks,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _UpcomingDeadlinesCard(events: state.upcomingEvents),
                  const SizedBox(height: AppSpacing.md),
                  _QuickNotesCard(notes: state.recentNotes),
                ],
              ),
      ),
    );
  }
}

/// The first open high-priority task of today, if there is one — what the
/// coral card is allowed to call "urgent".
TaskModel? _urgentOf(List<TaskModel> tasks) {
  for (final TaskModel task in tasks) {
    if (!task.isCompleted && task.priority == TaskPriority.high) {
      return task;
    }
  }

  return null;
}

/// The week capsule strip: seven real dates centred on today, today filled in/// the design's amber. Purely a readout on this screen (there is nothing here
/// to filter), so the capsules are not tappable buttons.
class _WeekCapsuleStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    return VWCapsuleStrip(
      children: <Widget>[
        for (int offset = -3; offset <= 3; offset++)
          VWDateCapsule(
            primary: DateFormat(
              'd MMM',
            ).format(today.add(Duration(days: offset))),
            secondary: offset == 0
                ? 'Today'
                : DateFormat('EEE').format(today.add(Duration(days: offset))),
            active: offset == 0,
            compact: true,
          ),
      ],
    );
  }
}

/// "Active Overview" — the mockup's section heading over this app's one-line
/// description of the screen.
class _OverviewHeading extends StatelessWidget {
  const _OverviewHeading();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Active Overview', style: theme.textTheme.headlineMedium),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(RoutePaths.financeSummary),
              child: const Text('See all'),
            ),
          ],
        ),
        Text(
          'Your money, tasks and schedule at a glance.',
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
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
    final String label = (sections.map(_label).toList()..sort()).join(', ');

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
                  // The finance card is backed by two providers: the balance
                  // aggregate and the current week's transactions.
                  ..invalidate(balanceProvider)
                  ..invalidate(watchTransactionsInRangeProvider)
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

/// The pistachio hero: kicker with the week's delta pill, the giant tabular
/// balance, the 7-day line, and a shelf carrying the sparkline.
class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard({
    required this.balance,
    required this.weeklyNetChange,
    required this.last7DaysNet,
    required this.hasData,
  });

  final double balance;
  final double weeklyNetChange;
  final List<DailyNet> last7DaysNet;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool positive = weeklyNetChange >= 0;
    final VWTactilePalette palette = vwTactilePalette(
      context,
      VWTactileTone.pistachio,
    );

    return VWTactileCard(
      tone: VWTactileTone.pistachio,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWTactileKicker(
            label: 'Total net balance',
            ink: palette.ink,
            dotColor: palette.ink,
            trailing: hasData && weeklyNetChange != 0
                ? _DeltaPill(
                    positive: positive,
                    label:
                        '${positive ? '+' : '-'}${formatMoney(weeklyNetChange.abs())}',
                    ink: palette.ink,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          if (!hasData)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: VWEmptyState(
                icon: Icons.receipt_long_outlined,
                message: 'No transactions yet.',
              ),
            )
          else ...<Widget>[
            Text(
              formatMoney(balance),
              style: theme.textTheme.displaySmall!.copyWith(color: palette.ink),
            ),
            const SizedBox(height: 2),
            Text(
              'past 7 days net ${positive ? '+' : '-'}${formatMoney(weeklyNetChange.abs())}',
              style: theme.textTheme.bodySmall!.copyWith(
                color: palette.softInk,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            VWCardShelf(
              leading: Text(
                'This week',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: palette.softInk,
                ),
              ),
              trailing: SizedBox(
                width: 96,
                height: 28,
                child: VWSparkline(
                  values: <double>[
                    for (final DailyNet day in last7DaysNet) day.net,
                  ],
                  color: palette.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The pill that reports the week's direction. Cold ink on the pistachio card,
/// so it is tinted from the card rather than from the semantic income/expense
/// pair which would fight the fill.
class _DeltaPill extends StatelessWidget {
  const _DeltaPill({
    required this.positive,
    required this.label,
    required this.ink,
  });

  final bool positive;
  final String label;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.10),
        borderRadius: AppRadii.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            positive ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: ink,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall!.copyWith(color: ink, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

/// The amber task-momentum card: the mockup's "Active Budget Momentum" slot
/// carrying this app's real analogue — today's focus list and its ring.
class _FocusCard extends ConsumerWidget {
  const _FocusCard({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TaskModel> shown = tasks.take(3).toList();
    final int done = tasks.where((TaskModel t) => t.isCompleted).length;
    final int total = tasks.length;
    final ThemeData theme = Theme.of(context);
    final VWTactilePalette palette = vwTactilePalette(
      context,
      VWTactileTone.amber,
    );

    return VWTactileCard(
      tone: VWTactileTone.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWTactileKicker(
            label: 'Active task momentum',
            ink: palette.ink,
            trailing: total > 0
                ? _ProgressRing(
                    value: done / total,
                    ink: palette.ink,
                    track: Colors.black.withValues(alpha: 0.12),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Today's Focus",
            style: theme.textTheme.headlineMedium!.copyWith(color: palette.ink),
          ),
          Text(
            total == 0 ? 'Nothing planned yet' : '$done of $total completed',
            style: theme.textTheme.bodySmall!.copyWith(color: palette.softInk),
          ),
          const SizedBox(height: AppSpacing.md),
          if (shown.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: VWEmptyState(
                icon: Icons.celebration_outlined,
                message: 'No tasks for today.',
              ),
            )
          else ...<Widget>[
            for (final TaskModel task in shown)
              _DashboardTaskRow(task: task, ink: palette.ink),
          ],
          const SizedBox(height: AppSpacing.xs),
          VWCardShelf(
            leading: Text(
              total == 0 ? 'Nothing due today' : '${total - done} left today',
              style: theme.textTheme.bodySmall!.copyWith(
                color: palette.softInk,
              ),
            ),
            trailing: VWPill(
              label: 'See all',
              icon: Icons.chevron_right,
              background: Colors.black.withValues(alpha: 0.10),
              foreground: palette.ink,
              onTap: () => context.go(RoutePaths.tasks),
            ),
          ),
        ],
      ),
    );
  }
}

/// One task row inside the amber card: a translucent capsule so it reads as a
/// nested surface rather than a second card.
class _DashboardTaskRow extends ConsumerWidget {
  const _DashboardTaskRow({required this.task, required this.ink});

  final TaskModel task;
  final Color ink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.10),
          borderRadius: AppRadii.row,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              task.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 16,
              color: ink,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall!.copyWith(
                  color: ink,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              taskPriorityLabel(task.priority),
              style: theme.textTheme.labelSmall!.copyWith(
                color: ink.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The coral urgent card — the mockup's loudest block. It only renders when
/// the app actually holds something urgent (a high-priority open task, else
/// the next event), so the screen never shouts about nothing.
class _UrgentCard extends StatelessWidget {
  const _UrgentCard({required this.task, required this.event});

  final TaskModel? task;
  final CalendarEventModel? event;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VWTactilePalette palette = vwTactilePalette(
      context,
      VWTactileTone.coral,
    );

    final String title = task?.title ?? event!.title;
    final String body = task?.description?.trim().isNotEmpty ?? false
        ? task!.description!.trim()
        : 'Flagged high priority';
    final DateTime? when = task?.dueDate ?? event?.startDateTime;
    final bool isTask = task != null;

    return VWTactileCard(
      tone: VWTactileTone.coral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWTactileKicker(
            label: isTask ? 'Urgent review' : 'Next event',
            ink: palette.ink,
            dotColor: palette.ink,
            trailing: VWCardAction(
              icon: isTask ? Icons.notifications_active : Icons.event_available,
              ink: palette.ink,
              onPressed: () =>
                  context.go(isTask ? RoutePaths.tasks : RoutePaths.calendar),
              tooltip: isTask ? 'Open tasks' : 'Open calendar',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium!.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall!.copyWith(color: palette.softInk),
          ),
          const SizedBox(height: AppSpacing.md),
          VWCardShelf(
            leading: Row(
              children: <Widget>[
                Icon(Icons.calendar_today, size: 14, color: palette.softInk),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    when == null
                        ? 'No due date'
                        : DateFormat.yMMMd().format(when),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: palette.softInk,
                    ),
                  ),
                ),
              ],
            ),
            trailing: VWPill(
              label: isTask
                  ? taskPriorityLabel(task!.priority)
                  : (event!.isAllDay
                        ? 'All day'
                        : DateFormat.Hm().format(event!.startDateTime)),
              background: Colors.black.withValues(alpha: 0.10),
              foreground: palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// The mockup's bento pair: two real aggregates, each on its own tile.
class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.last7DaysNet, required this.tasks});

  final List<DailyNet> last7DaysNet;
  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final double weekNet = last7DaysNet.fold<double>(
      0,
      (double sum, DailyNet day) => sum + day.net,
    );
    final int open = tasks.where((TaskModel t) => !t.isCompleted).length;
    final int done = tasks.length - open;
    final Brightness brightness = Theme.of(context).brightness;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: VWBentoTile(
              label: 'Weekly net',
              value: formatMoney(weekNet),
              caption: 'across the last 7 days',
              captionColor: weekNet >= 0
                  ? AppColors.incomeFor(brightness)
                  : AppColors.expenseFor(brightness),
              icon: Icons.savings_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: VWBentoTile(
              label: 'Active tasks',
              value: '$open left',
              caption: '$done completed today',
              icon: Icons.task_alt,
            ),
          ),
        ],
      ),
    );
  }
}

/// Upcoming schedule snapshot: the mockup's event card with its shelves.
class _UpcomingDeadlinesCard extends StatelessWidget {
  const _UpcomingDeadlinesCard({required this.events});

  final List<CalendarEventModel> events;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'NEXT EVENT',
                  style: theme.textTheme.labelSmall!.copyWith(
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              VWPill(
                label: 'See all',
                icon: Icons.chevron_right,
                onTap: () => context.go(RoutePaths.calendar),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: VWEmptyState(
                icon: Icons.event_available_outlined,
                message: 'Nothing scheduled coming up.',
              ),
            )
          else
            for (final CalendarEventModel event in events.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: AppRadii.row,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(event.colorValue),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              DateFormat.yMMMd().add_Hm().format(
                                event.startDateTime,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// "Pinned Note" snapshot from the mockup: the most recent notes, one line of
/// body each, tap-through to the editor.
class _QuickNotesCard extends StatelessWidget {
  const _QuickNotesCard({required this.notes});

  final List<NoteModel> notes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'RECENT NOTE',
                  style: theme.textTheme.labelSmall!.copyWith(
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              VWPill(
                label: 'See all',
                icon: Icons.chevron_right,
                onTap: () => context.go(RoutePaths.notes),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: VWEmptyState(
                icon: Icons.sticky_note_2_outlined,
                message: 'No notes yet.',
              ),
            )
          else
            for (final NoteModel note in notes.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  onTap: () => context.go(RoutePaths.noteEditorFor(note.id)),
                  borderRadius: AppRadii.row,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: AppRadii.row,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          note.title.isEmpty ? 'Untitled' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          note.contentPlainText.trim().isEmpty
                              ? 'Empty note'
                              : note.contentPlainText.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Small circular completion ring, tracking the done/total ratio.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.value,
    required this.ink,
    required this.track,
  });

  final double value;
  final Color ink;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: <Widget>[
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 3.5,
            strokeCap: StrokeCap.round,
            color: ink,
            backgroundColor: track,
          ),
          Center(
            child: Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.labelSmall!.copyWith(
                letterSpacing: 0.2,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
