import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/providers/tasks_providers.dart';

part 'dashboard_provider.g.dart';

/// Which feature a dashboard card belongs to, so a failed stream can be
/// reported against the card that actually broke (P5-T2).
enum DashboardSection { tasks, finance, calendar, notes }

/// Aggregated, read-only snapshot of the four feature streams (plan P3-DASH-1).
class DashboardState {
  const DashboardState({
    required this.todayTasks,
    required this.balance,
    required this.weeklyNetChange,
    required this.upcomingEvents,
    required this.recentNotes,
    this.isLoading = false,
    this.failedSections = const <DashboardSection>{},
  });

  const DashboardState.empty()
      : todayTasks = const <TaskModel>[],
        balance = 0,
        weeklyNetChange = 0,
        upcomingEvents = const <CalendarEventModel>[],
        recentNotes = const <NoteModel>[],
        isLoading = false,
        failedSections = const <DashboardSection>{};

  final List<TaskModel> todayTasks;
  final double balance;
  final double weeklyNetChange;
  final List<CalendarEventModel> upcomingEvents;
  final List<NoteModel> recentNotes;

  /// True only while *every* feature stream is still loading, so the dashboard
  /// shows one spinner instead of four misleadingly-empty cards.
  final bool isLoading;

  /// Feature streams that errored. A single failure must not blank the whole
  /// dashboard, but it must be visible rather than silently reading as "empty".
  final Set<DashboardSection> failedSections;
}

/// Combines the feature repositories' streams into a single [DashboardState].
///
/// Each `ref.watch` re-runs this function whenever the underlying stream emits,
/// so completing a task or logging a transaction updates the Dashboard with no
/// manual refresh.
@riverpod
DashboardState dashboard(Ref ref) {
  final AsyncValue<List<TaskModel>> tasks = ref.watch(watchTasksDueTodayProvider);
  // Aggregates only: the balance is an Isar `sum()` and the week's net comes
  // from a range query, so the dashboard never pulls the whole history into
  // memory just to add two numbers up (plan P5-T5).
  final AsyncValue<double> balanceAsync = ref.watch(balanceProvider);
  final DateTime now = DateTime.now();
  final DateTime weekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final AsyncValue<List<TransactionModel>> weekTransactions =
      ref.watch(
    watchTransactionsInRangeProvider(weekStart, weekStart.add(const Duration(days: 7))),
  );
  final AsyncValue<List<CalendarEventModel>> upcomingEvents =
      ref.watch(watchUpcomingEventsProvider);
  final AsyncValue<List<NoteModel>> allNotesAsync =
      ref.watch(watchAllNotesProvider);

  final bool isLoading = tasks.isLoading &&
      balanceAsync.isLoading &&
      weekTransactions.isLoading &&
      upcomingEvents.isLoading &&
      allNotesAsync.isLoading;

  final Set<DashboardSection> failedSections = <DashboardSection>{
    if (tasks.hasError) DashboardSection.tasks,
    if (balanceAsync.hasError || weekTransactions.hasError)
      DashboardSection.finance,
    if (upcomingEvents.hasError) DashboardSection.calendar,
    if (allNotesAsync.hasError) DashboardSection.notes,
  };

  final double balance = balanceAsync.value ?? 0;

  final double weeklyNetChange = (weekTransactions.value ??
          const <TransactionModel>[])
      .fold<double>(
        0,
        (double acc, TransactionModel t) =>
            acc + (t.type == TransactionType.income ? t.amount : -t.amount),
      );

  final List<NoteModel> recentNotes =
      (allNotesAsync.value ?? const <NoteModel>[]).toList()
        ..sort((NoteModel a, NoteModel b) => b.updatedAt.compareTo(a.updatedAt));

  return DashboardState(
    todayTasks: tasks.value ?? const <TaskModel>[],
    balance: balance,
    weeklyNetChange: weeklyNetChange,
    upcomingEvents: upcomingEvents.value ?? const <CalendarEventModel>[],
    recentNotes: recentNotes.take(2).toList(),
    isLoading: isLoading,
    failedSections: failedSections,
  );
}
