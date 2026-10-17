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

/// Aggregated, read-only snapshot of the four feature streams (plan P3-DASH-1).
class DashboardState {
  const DashboardState({
    required this.todayTasks,
    required this.balance,
    required this.weeklyNetChange,
    required this.upcomingEvents,
    required this.recentNotes,
  });

  const DashboardState.empty()
      : todayTasks = const <TaskModel>[],
        balance = 0,
        weeklyNetChange = 0,
        upcomingEvents = const <CalendarEventModel>[],
        recentNotes = const <NoteModel>[];

  final List<TaskModel> todayTasks;
  final double balance;
  final double weeklyNetChange;
  final List<CalendarEventModel> upcomingEvents;
  final List<NoteModel> recentNotes;
}

/// Combines the feature repositories' streams into a single [DashboardState].
///
/// Each `ref.watch` re-runs this function whenever the underlying stream emits,
/// so completing a task or logging a transaction updates the Dashboard with no
/// manual refresh.
@riverpod
DashboardState dashboard(Ref ref) {
  final List<TaskModel> todayTasks =
      ref.watch(watchTasksDueTodayProvider).value ?? const <TaskModel>[];
  final List<TransactionModel> transactions =
      ref.watch(watchAllTransactionsProvider).value ?? const <TransactionModel>[];
  final List<CalendarEventModel> upcomingEvents =
      ref.watch(watchUpcomingEventsProvider).value ?? const <CalendarEventModel>[];
  final List<NoteModel> allNotes =
      ref.watch(watchAllNotesProvider).value ?? const <NoteModel>[];

  final double balance = transactions.fold<double>(
    0,
    (double acc, TransactionModel t) =>
        acc + (t.type == TransactionType.income ? t.amount : -t.amount),
  );

  final DateTime now = DateTime.now();
  final DateTime weekStart =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final double weeklyNetChange = transactions
      .where((TransactionModel t) => !t.date.isBefore(weekStart))
      .fold<double>(
        0,
        (double acc, TransactionModel t) =>
            acc + (t.type == TransactionType.income ? t.amount : -t.amount),
      );

  final List<NoteModel> recentNotes = allNotes.toList()
    ..sort((NoteModel a, NoteModel b) => b.updatedAt.compareTo(a.updatedAt));

  return DashboardState(
    todayTasks: todayTasks,
    balance: balance,
    weeklyNetChange: weeklyNetChange,
    upcomingEvents: upcomingEvents,
    recentNotes: recentNotes.take(2).toList(),
  );
}
