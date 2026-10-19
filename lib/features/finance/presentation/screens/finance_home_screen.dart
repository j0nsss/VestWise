import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_animated_list_item.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_delayed.dart';
import 'package:vestwise/core/widgets/vw_fade_through.dart';
import 'package:vestwise/core/widgets/vw_fab.dart';
import 'package:vestwise/core/widgets/vw_luminous.dart';
import 'package:vestwise/core/widgets/vw_screen_header.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_list_tile.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_row_skeleton.dart';

/// Finance home: current balance card + reverse-chronological transactions
/// grouped by day (plan P3-FIN-2).
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
            const VWScreenHeader(
              title: AppStrings.finance,
              actions: <Widget>[
                _HeaderSummaryAction(),
              ],
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

    final List<Widget> slivers = <Widget>[
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: _BalanceCard(),
        ),
      ),
    ];

    if (transactions.isEmpty) {
      slivers.add(
        // Keep the default `hasScrollBody: true` so the empty state fills and
        // scrolls within the remaining viewport.
        SliverFillRemaining(
          child: VWEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No transactions yet',
            message: 'Log your first income or expense to see your balance.',
            actionLabel: 'Add transaction',
            onAction: () => context.go(RoutePaths.financeAdd),
          ),
        ),
      );
    } else {
      for (final _DayGroup group in groups) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Text(
                group.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        );
        slivers.add(
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
        );
      }
      if (hasMore) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
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
        );
      }
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 96)));
    }

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

/// The finance hero card (Phase 13 mockup) — the sheet-gradient surface and
/// ambient orb bloom, holding the balance our data actually has: the sum of
/// the stored transactions.
///
/// The mockup's month-over-month delta and privacy eye are deliberately
/// absent: there is no month history projection and no hide-amounts setting
/// yet, and the card does not invent numbers it cannot back.
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

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<double> balance = ref.watch(balanceProvider);

    return DecoratedBox(
      decoration: vwHeroCardDecoration(context),
      child: ClipRRect(
        borderRadius: AppRadii.card,
        child: Stack(
          children: <Widget>[
            // Ambient bloom, purely decorative.
            const Positioned(
              right: -48,
              top: -48,
              child: VWGlowOrb(
                color: AppColors.accentViolet,
                size: 176,
                opacity: 0.2,
                alignment: Alignment.center,
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: VWGlowOrb(
                color: AppColors.accentMintFor(theme.brightness),
                size: 144,
                opacity: 0.15,
                alignment: Alignment.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentMintFor(theme.brightness),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'NET LIQUID ASSETS',
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  balance.when(
                    loading: () =>
                        Text('—', style: theme.textTheme.displaySmall),
                    error: (Object error, StackTrace stack) =>
                        Text('—', style: theme.textTheme.displaySmall),
                    data: (double value) => Text(
                      formatMoney(value),
                      style: theme.textTheme.displaySmall!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
