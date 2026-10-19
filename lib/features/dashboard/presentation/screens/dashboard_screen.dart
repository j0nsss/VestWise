import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_luminous.dart';
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

/// Dashboard, restyled Phase 13 per the Stitch mockup: ambient glow orbs, a
/// greeting block, a luminous hero balance card, a "Today's Focus" checklist
/// card with a progress ring, then the schedule and notes snapshots.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardState state = ref.watch(dashboardProvider);

    final Brightness brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Ambient bloom behind the whole dashboard, like the mockup's
          // decorative orbs. Excluded from semantics by VWGlowOrb itself.
          const Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: <Widget>[
                  VWGlowOrb(
                    color: AppColors.accentViolet,
                    size: 220,
                    alignment: Alignment(-1.15, -0.55),
                  ),
                  VWGlowOrb(
                    color: AppColors.accentMint,
                    size: 190,
                    alignment: Alignment(1.2, -0.05),
                    opacity: 0.08,
                  ),
          VWGlowOrb(
            color: AppColors.accentViolet,
            size: 230,
            alignment: Alignment(1.3, 0.45),
            opacity: 0.06,
          ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      vwDockClearance,
                    ),
                    children: <Widget>[
                      const VWScreenHeader(title: 'Dashboard'),
                      const SizedBox(height: AppSpacing.sm),
                      _DateBadge(),
                      const SizedBox(height: AppSpacing.xs),
                      _Greeting(),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your money, tasks and schedule at a glance.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.failedSections.isNotEmpty) ...<Widget>[
                        _LoadErrorBanner(sections: state.failedSections),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      _BalanceSummaryCard(
                        balance: state.balance,
                        weeklyNetChange: state.weeklyNetChange,
                        last7DaysNet: state.last7DaysNet,
                        hasData: state.hasFinanceData,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _TodayTasksCard(tasks: state.todayTasks),
                      const SizedBox(height: AppSpacing.lg),
                      _UpcomingDeadlinesCard(events: state.upcomingEvents),
                      const SizedBox(height: AppSpacing.lg),
                      _QuickNotesCard(notes: state.recentNotes),
                      SizedBox(
                        height: brightness == Brightness.dark ? 0 : 0,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Local date under a pulsing mint dot, as the mockup's status pill.
class _DateBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadii.chip,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.circle, size: 6, color: theme.colorScheme.secondary),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: theme.textTheme.labelSmall!.copyWith(
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Time-of-day greeting with the violet→mint gradient accent the mockup paints
/// on the name we do not have — so the block still lands as "designed".
class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int hour = DateTime.now().hour;
    final String greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return ShaderMask(
      shaderCallback: (Rect bounds) => const LinearGradient(
        colors: <Color>[AppColors.accentViolet, AppColors.accentMint],
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        greeting,
        style: Theme.of(context).textTheme.titleLarge,
      ),
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

/// The luminous hero card: gradient canvas + inner blooms, uppercase label,
/// giant tabular metric, weekly delta pill and the 7-day sparkline.
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
    final Color momentum = positive
        ? theme.colorScheme.secondary
        : theme.colorScheme.tertiary;

    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: <Widget>[
                VWGlowOrb(
                  color: AppColors.accentViolet,
                  size: 180,
                  alignment: Alignment.topRight,
                  opacity: 0.16,
                ),
                VWGlowOrb(
                  color: AppColors.accentMint,
                  size: 150,
                  alignment: Alignment.bottomLeft,
                  opacity: 0.12,
                ),
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: AppRadii.card,
          child: ColoredBox(
            color: AppColors.surfaceContainerFor(theme.brightness),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _IconTile(
                        size: 32,
                        icon: Icons.account_balance_wallet,
                        color: theme.colorScheme.primary,
                        background: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'TOTAL NET BALANCE',
                        style: theme.textTheme.labelMedium!.copyWith(
                          letterSpacing: 1.0,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (hasData && weeklyNetChange != 0)
                        _StatusPill(
                          icon: positive
                              ? Icons.trending_up
                              : Icons.trending_down,
                          label:
                              '${positive ? '+' : '-'}${formatMoney(weeklyNetChange.abs())}',
                          color: momentum,
                        ),
                    ],
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                formatMoney(balance),
                                style: theme.textTheme.displaySmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'past 7 days net ${positive ? '+' : '-'}${formatMoney(weeklyNetChange.abs())}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 96,
                          height: 48,
                          child: VWSparkline(
                            values: <double>[
                              for (final DailyNet day in last7DaysNet) day.net,
                            ],
                            color: momentum,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _QuickActionPill(
                            icon: Icons.add_circle_outline,
                            label: 'Add record',
                            filled: true,
                            onTap: () => context.go(RoutePaths.financeAdd),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _QuickActionPill(
                            icon: Icons.insights_outlined,
                            label: 'Summary',
                            onTap: () => context.go(RoutePaths.financeSummary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Today's Focus": header with the radial complete-ring, then up to three
/// tactile task rows with priority pills, completed rows dimmed.
class _TodayTasksCard extends ConsumerWidget {
  const _TodayTasksCard({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TaskModel> shown = tasks.take(3).toList();
    final int done = tasks.where((TaskModel t) => t.isCompleted).length;
    final int total = tasks.length;
    final ThemeData theme = Theme.of(context);

    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _IconTile(
                size: 32,
                icon: Icons.check_circle,
                color: theme.colorScheme.primary,
                background: theme.colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Today's Focus",
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    total == 0 ? 'Nothing planned yet' : '$done of $total completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (total > 0) _ProgressRing(value: done / total),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (shown.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: VWEmptyState(
                icon: Icons.celebration_outlined,
                message: 'No tasks for today.',
              ),
            )
          else ...<Widget>[
            for (final TaskModel task in shown)
              _DashboardTaskRow(task: task),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(RoutePaths.tasks),
                child: const Text('See all'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardTaskRow extends ConsumerWidget {
  const _DashboardTaskRow({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppTag priorityTag = switch (task.priority) {
      TaskPriority.high => AppTag.red,
      TaskPriority.medium => AppTag.yellow,
      TaskPriority.low => AppTag.blue,
    };
    final AppTagColor pill = AppColors.tagFor(priorityTag, theme.brightness);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.circle,
                size: 8,
                color: taskPriorityColor(task.priority),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: task.isCompleted
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                          decoration: TextDecoration.lineThrough,
                        )
                      : theme.textTheme.titleSmall,
                ),
              ),
              Text(
                taskPriorityLabel(task.priority),
                style: theme.textTheme.labelSmall!.copyWith(color: pill.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upcoming schedule snapshot: the "Next Event" card from the mockup.
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
              _IconTile(
                size: 28,
                icon: Icons.calendar_month,
                color: theme.colorScheme.secondary,
                background: theme.colorScheme.secondary.withValues(alpha: 0.15),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'NEXT EVENT',
                style: theme.textTheme.labelSmall!.copyWith(
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(RoutePaths.calendar),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
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
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(event.colorValue),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
        ],
      ),
    );
  }
}

/// "Pinned Note" snapshot from the mockup: the most recent note, one line of
/// body, tap-through to the editor.
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
              _IconTile(
                size: 28,
                icon: Icons.sticky_note_2,
                color: theme.colorScheme.primary,
                background: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'RECENT NOTE',
                style: theme.textTheme.labelSmall!.copyWith(
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(RoutePaths.notes),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
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
        ],
      ),
    );
  }
}

/// The tinted rounded icon tile the mockup puts in front of every card label.
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.size,
    required this.icon,
    required this.color,
    required this.background,
  });

  final double size;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: size * 0.55, color: color),
      ),
    );
  }
}

/// The full-pill status badge (tinted bg, saturated label, leading chevron).
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadii.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall!.copyWith(color: color, letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small circular completion ring, tracking the done/total ratio.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

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
            color: theme.colorScheme.primaryContainer,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          Center(
            child: Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.labelSmall!.copyWith(
                letterSpacing: 0.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the hero card's pill actions — filled violet, or quiet surface-high
/// with a tinted accent icon, exactly the mockup's quick-action row.
class _QuickActionPill extends StatefulWidget {
  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  State<_QuickActionPill> createState() => _QuickActionPillState();
}

class _QuickActionPillState extends State<_QuickActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return AnimatedScale(
      scale: _pressed ? AppMotion.pressedScale : 1,
      duration: motionDuration(context, AppMotion.stateChange),
      curve: AppMotion.standardCurve,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: Semantics(
          button: true,
          label: widget.label,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadii.chip,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.filled
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: AppRadii.chip,
                boxShadow: widget.filled
                    ? vwGlowShadow(alpha: 0.3, offsetY: 4)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.filled
                          ? scheme.onPrimary
                          : scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: widget.filled ? scheme.onPrimary : scheme.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
