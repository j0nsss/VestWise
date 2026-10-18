import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_list_tile.dart';

/// Finance home: current balance card + reverse-chronological transactions
/// grouped by day (plan P3-FIN-2).
class FinanceHomeScreen extends ConsumerWidget {
  const FinanceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TransactionModel>> transactionsAsync =
        ref.watch(watchAllTransactionsProvider);

    return Scaffold(
      appBar: VWAppBar(
        title: AppStrings.finance,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Summary',
            onPressed: () => context.go(RoutePaths.financeSummary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RoutePaths.financeAdd),
        child: const Icon(Icons.add),
      ),
      body: transactionsAsync.when(
        loading: () => const VWLoadingIndicator(),
        error: (Object error, StackTrace stack) => const VWEmptyState(
          icon: Icons.error_outline,
          message: 'Could not load your transactions.',
        ),
        data: (List<TransactionModel> transactions) =>
            _buildBody(context, ref, transactions),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<TransactionModel> transactions,
  ) {
    final List<_DayGroup> groups = _groupByDay(transactions);

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
              return TransactionListTile(
                transaction: transaction,
                onTap: () =>
                    context.go(RoutePaths.financeAddFor(transaction.id)),
              );
            },
          ),
        );
      }
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 88)));
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

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<double> balance = ref.watch(balanceProvider);

    return VWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Current balance',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xs),
          balance.when(
            loading: () => Text('—', style: theme.textTheme.headlineMedium),
            error: (Object error, StackTrace stack) =>
                Text('—', style: theme.textTheme.headlineMedium),
            data: (double value) => Text(
              formatMoney(value),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
