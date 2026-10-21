import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_animated_list_item.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_delayed.dart';
import 'package:vestwise/core/widgets/vw_fade_through.dart';
import 'package:vestwise/core/widgets/vw_fab.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';
import 'package:vestwise/core/widgets/vw_screen_header.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_list_tile.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_row_skeleton.dart';

/// Finance home, restyled Phase 14 per the "Omotive Style" mockup: the header's
/// Create pill, the month capsule strip, then the pistachio balance hero, the
/// amber outflow card over the coral largest-expense card (both bounded to the
/// current month), and the reverse-chronological log grouped by day.
///
/// The mockup's burn-rate cap, "Active Accounts / Deck View" and auto-stash
/// footer are absent: there is no budget model and no stash setting to read, and
/// the screen does not invent them (P5-T2's honest-UI rule).
class FinanceHomeScreen extends ConsumerStatefulWidget {
  const FinanceHomeScreen({super.key});

  @override
  ConsumerState<FinanceHomeScreen> createState() => _FinanceHomeScreenState();
}

class _FinanceHomeScreenState extends ConsumerState<FinanceHomeScreen> {
  /// Size of the window of history currently on screen. Grows by
  /// [financeHistoryPageSize] each time the user taps "Load older".
  int _visibleCount = financeHistoryPageSize;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<TransactionModel>> transactionsAsync = ref.watch(
      watchRecentTransactionsProvider(_visibleCount),
    );

    return Scaffold(
      floatingActionButton: VWFab(
        tooltip: 'Add transaction',
        onPressed: () => context.go(RoutePaths.financeAdd),
        child: const Icon(Icons.add),
      ),
      // One comfortable gap over the floating dock (Phase 13).
      floatingActionButtonLocation: const VWFabLocation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            VWScreenHeader(
              title: AppStrings.finance,
              onCreate: () => context.go(RoutePaths.financeAdd),
              actions: const <Widget>[_HeaderSummaryAction()],
            ),
            Expanded(
              child: VWFadeThrough(
                child: transactionsAsync.when(
                  loading: () => const VWDelayed(
                    key: ValueKey<String>('transactions-loading'),
                    child: VWSkeletonList(row: TransactionRowSkeleton()),
                  ),
                  error: (Object error, StackTrace stack) => VWEmptyState(
                    key: const ValueKey<String>('transactions-error'),
                    icon: Icons.error_outline,
                    title: 'Could not load your transactions',
                    message: 'Something went wrong reading your finance data.',
                    actionLabel: 'Retry',
                    onAction: () => ref.invalidate(
                      watchRecentTransactionsProvider(_visibleCount),
                    ),
                  ),
                  data: (List<TransactionModel> transactions) =>
                      _buildBody(context, transactions),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<TransactionModel> transactions) {
    final List<_DayGroup> groups = _groupByDay(transactions);
    // A full window means there may be older rows left to fetch.
    final bool hasMore = transactions.length == _visibleCount;
    final ThemeData theme = Theme.of(context);

    final List<Widget> slivers = <Widget>[
      const SliverToBoxAdapter(child: _MonthCapsuleStrip()),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            vwPageMargin,
            AppSpacing.sm,
            vwPageMargin,
            0,
          ),
          child: _BalanceCard(),
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            vwPageMargin,
            AppSpacing.md,
            vwPageMargin,
            0,
          ),
          child: _MonthInsights(),
        ),
      ),
      if (transactions.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              vwPageMargin,
              AppSpacing.md,
              vwPageMargin,
              vwDockClearance,
            ),
            child: VWEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No transactions yet',
              message: 'Log your first income or expense to see your balance.',
              actionLabel: 'Add transaction',
              onAction: () => context.go(RoutePaths.financeAdd),
            ),
          ),
        )
      else ...<Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              vwPageMargin,
              AppSpacing.lg,
              vwPageMargin,
              0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'RECENT ACTIVITY',
                    style: theme.textTheme.labelSmall!.copyWith(
                      letterSpacing: 0.8,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                VWPill(
                  label: 'Summary',
                  icon: Icons.chevron_right,
                  onTap: () => context.go(RoutePaths.financeSummary),
                ),
              ],
            ),
          ),
        ),
        for (final _DayGroup group in groups) ...<Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                vwPageMargin,
                AppSpacing.lg,
                vwPageMargin,
                AppSpacing.xs,
              ),
              child: Text(
                group.label,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: group.items.length,
            itemBuilder: (BuildContext context, int index) {
              final TransactionModel transaction = group.items[index];
              final Widget tile = TransactionListTile(
                transaction: transaction,
                onTap: () =>
                    context.go(RoutePaths.financeAddFor(transaction.id)),
              );
              final Key key = ValueKey<int>(transaction.id);
              return VWAnimatedListItem.animates(index)
                  ? VWAnimatedListItem(key: key, child: tile)
                  : KeyedSubtree(key: key, child: tile);
            },
          ),
        ],
        if (hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                vwPageMargin,
                AppSpacing.lg,
                vwPageMargin,
                0,
              ),
              child: VWButton(
                label: 'Load older',
                variant: VWButtonVariant.secondary,
                expand: true,
                onPressed: () =>
                    setState(() => _visibleCount += financeHistoryPageSize),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: vwDockClearance)),
      ],
    ];

    return CustomScrollView(slivers: slivers);
  }

  List<_DayGroup> _groupByDay(List<TransactionModel> transactions) {
    final List<_DayGroup> groups = <_DayGroup>[];
    for (final TransactionModel transaction in transactions) {
      final DateTime day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (groups.isNotEmpty && groups.last.day == day) {
        groups.last.items.add(transaction);
      } else {
        groups.add(_DayGroup(day: day, items: <TransactionModel>[transaction]));
      }
    }
    return groups;
  }
}

/// The month capsule strip the Omotive mockup opens with: the last five months,
/// the current one filled amber. A readout on this screen — the log below is
/// always reverse-chronological, not month-filtered.
class _MonthCapsuleStrip extends StatelessWidget {
  const _MonthCapsuleStrip();

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return VWCapsuleStrip(
      padding: const EdgeInsets.symmetric(horizontal: vwPageMargin),
      children: <Widget>[
        for (int offset = -4; offset <= 0; offset++)
          Builder(
            builder: (BuildContext context) {
              final DateTime month = DateTime(now.year, now.month + offset);
              return VWDateCapsule(
                primary: DateFormat('yyyy').format(month),
                secondary: DateFormat('MMM').format(month),
                active: offset == 0,
                compact: true,
              );
            },
          ),
      ],
    );
  }
}

/// The finance hero card — the pistachio block holding the balance our data
/// actually has: the sum of the stored transactions.
///
/// The mockup's month-over-month delta and privacy eye are deliberately
/// absent: there is no month history projection and no hide-amounts setting
/// yet, and the card does not invent numbers it cannot back.
class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<double> balance = ref.watch(balanceProvider);
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
            label: 'Net liquid balance',
            ink: palette.ink,
            dotColor: palette.ink,
          ),
          const SizedBox(height: AppSpacing.md),
          balance.when(
            loading: () => Text(
              '—',
              style: theme.textTheme.displaySmall!.copyWith(color: palette.ink),
            ),
            error: (Object error, StackTrace stack) => Text(
              '—',
              style: theme.textTheme.displaySmall!.copyWith(color: palette.ink),
            ),
            data: (double value) => Text(
              formatMoney(value),
              style: theme.textTheme.displaySmall!.copyWith(color: palette.ink),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          VWCardShelf(
            leading: Row(
              children: <Widget>[
                Icon(Icons.calendar_today, size: 14, color: palette.softInk),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'As of ${DateFormat.yMMMd().format(DateTime.now())}',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: palette.softInk,
                  ),
                ),
              ],
            ),
            trailing: VWPill(
              label: 'Summary',
              icon: Icons.chevron_right,
              background: Colors.black.withValues(alpha: 0.10),
              foreground: palette.ink,
              onTap: () => context.go(RoutePaths.financeSummary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The month's two aggregates the mockup shouts about — an amber outflow card
/// and, when there is one, the coral largest-expense card.
///
/// Both are bounded range queries over the current and previous month, so the
/// "vs last month" line is a real comparison rather than a decoration. While
/// they load (or if the query fails) the cards simply are not there.
class _MonthInsights extends ConsumerWidget {
  const _MonthInsights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);
    final DateTime nextMonth = DateTime(now.year, now.month + 1);
    final DateTime prevMonthStart = DateTime(now.year, now.month - 1);

    final AsyncValue<List<TransactionModel>> month = ref.watch(
      watchTransactionsInRangeProvider(monthStart, nextMonth),
    );
    final AsyncValue<List<TransactionModel>> previous = ref.watch(
      watchTransactionsInRangeProvider(prevMonthStart, monthStart),
    );

    // A failed or still-loading range query must not put a fake card on screen.
    if (month.hasError || month.isLoading) {
      return const SizedBox.shrink();
    }

    final List<TransactionModel> rows =
        month.value ?? const <TransactionModel>[];
    final double outflow = _sum(rows, TransactionType.expense);
    final double inflow = _sum(rows, TransactionType.income);
    final double? previousOutflow = previous.hasError
        ? null
        : (previous.value == null
              ? null
              : _sum(previous.value!, TransactionType.expense));

    final TransactionModel? largest = _largestExpense(rows);

    return Column(
      children: <Widget>[
        _OutflowCard(
          outflow: outflow,
          inflow: inflow,
          previousOutflow: previousOutflow,
          transactionCount: rows.length,
        ),
        if (largest != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _LargestExpenseCard(transaction: largest),
        ],
      ],
    );
  }

  static double _sum(List<TransactionModel> rows, TransactionType type) => rows
      .where((TransactionModel t) => t.type == type)
      .fold<double>(0, (double sum, TransactionModel t) => sum + t.amount);

  static TransactionModel? _largestExpense(List<TransactionModel> rows) {
    TransactionModel? largest;
    for (final TransactionModel row in rows) {
      if (row.type != TransactionType.expense) {
        continue;
      }
      if (largest == null || row.amount > largest.amount) {
        largest = row;
      }
    }

    return largest;
  }
}

/// The amber "Outflow Velocity" card, carrying this month's real outflow and
/// its comparison against the month before.
class _OutflowCard extends StatelessWidget {
  const _OutflowCard({
    required this.outflow,
    required this.inflow,
    required this.previousOutflow,
    required this.transactionCount,
  });

  final double outflow;
  final double inflow;
  final double? previousOutflow;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VWTactilePalette palette = vwTactilePalette(
      context,
      VWTactileTone.amber,
    );

    final String comparison;
    if (previousOutflow == null) {
      comparison = 'no comparable month yet';
    } else if (previousOutflow == 0) {
      comparison = 'nothing spent last month';
    } else {
      final double delta =
          (outflow - previousOutflow!) / previousOutflow! * 100;
      comparison =
          '${delta >= 0 ? '+' : '-'}${delta.abs().toStringAsFixed(0)}% vs last month';
    }

    return VWTactileCard(
      tone: VWTactileTone.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWTactileKicker(
            label: 'Outflow velocity',
            ink: palette.ink,
            trailing: VWCardAction(
              icon: Icons.tune,
              ink: palette.ink,
              tooltip: 'Open summary',
              onPressed: () => context.go(RoutePaths.financeSummary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            formatMoney(outflow),
            style: theme.textTheme.headlineLarge!.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 2),
          Text(
            'this month · $comparison',
            style: theme.textTheme.bodySmall!.copyWith(color: palette.softInk),
          ),
          const SizedBox(height: AppSpacing.md),
          VWCardShelf(
            leading: Row(
              children: <Widget>[
                Icon(Icons.savings_outlined, size: 14, color: palette.softInk),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  transactionCount == 1
                      ? '1 record this month'
                      : '$transactionCount records this month',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: palette.softInk,
                  ),
                ),
              ],
            ),
            trailing: VWPill(
              label: '+${formatMoney(inflow)} in',
              background: Colors.black.withValues(alpha: 0.10),
              foreground: palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// The coral card for the single largest expense of the month — the mockup's
/// "Largest Expense" block, driven by a real row.
class _LargestExpenseCard extends StatelessWidget {
  const _LargestExpenseCard({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VWTactilePalette palette = vwTactilePalette(
      context,
      VWTactileTone.coral,
    );
    final String label = transaction.note?.trim().isNotEmpty ?? false
        ? transaction.note!.trim()
        : transaction.category.value?.name ?? 'Uncategorised';

    return VWTactileCard(
      tone: VWTactileTone.coral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VWTactileKicker(
            label: 'Largest expense',
            ink: palette.ink,
            trailing: VWCardAction(
              icon: Icons.receipt_long,
              ink: palette.ink,
              tooltip: 'Open transaction',
              onPressed: () =>
                  context.go(RoutePaths.financeAddFor(transaction.id)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium!.copyWith(color: palette.ink),
          ),
          Text(
            '-${formatMoney(transaction.amount)}',
            style: theme.textTheme.bodySmall!.copyWith(color: palette.softInk),
          ),
          const SizedBox(height: AppSpacing.md),
          VWCardShelf(
            leading: Row(
              children: <Widget>[
                Icon(Icons.calendar_today, size: 14, color: palette.softInk),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  DateFormat.yMMMd().format(transaction.date),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: palette.softInk,
                  ),
                ),
              ],
            ),
            trailing: VWPill(
              label: 'This month',
              background: Colors.black.withValues(alpha: 0.10),
              foreground: palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// The mockup's summary entry point: the bar-chart icon that used to live in
/// the app bar, now one of the header's trailing actions.
class _HeaderSummaryAction extends StatelessWidget {
  const _HeaderSummaryAction();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.bar_chart),
      tooltip: 'Summary',
      onPressed: () => context.go(RoutePaths.financeSummary),
    );
  }
}

class _DayGroup {
  _DayGroup({required this.day, required this.items});

  final DateTime day;
  final List<TransactionModel> items;

  String get label {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int diff = today.difference(day).inDays;
    if (diff == 0) {
      return 'Today';
    }
    if (diff == 1) {
      return 'Yesterday';
    }
    return DateFormat.yMMMMEEEEd().format(day);
  }
}
