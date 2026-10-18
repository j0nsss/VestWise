import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_section_header.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';
import 'package:vestwise/features/finance/presentation/widgets/category_breakdown.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';

enum _Range { week, month }

/// Weekly/monthly income-vs-expense chart and category spend breakdown
/// (plan P3-FIN-4).
class FinanceSummaryScreen extends ConsumerStatefulWidget {
  const FinanceSummaryScreen({super.key});

  @override
  ConsumerState<FinanceSummaryScreen> createState() =>
      _FinanceSummaryScreenState();
}

class _FinanceSummaryScreenState extends ConsumerState<FinanceSummaryScreen> {
  _Range _range = _Range.week;

  @override
  Widget build(BuildContext context) {
    // Query only the selected period instead of loading all history and
    // filtering it in Dart (plan P5-T5).
    final (DateTime start, DateTime end) = _bounds(_range);
    final AsyncValue<List<TransactionModel>> transactionsAsync =
        ref.watch(watchTransactionsInRangeProvider(start, end));

    return Scaffold(
      appBar: const VWAppBar(title: 'Summary'),
      body: transactionsAsync.when(
        loading: () => const VWLoadingIndicator(),
        error: (Object error, StackTrace stack) => VWEmptyState(
          icon: Icons.error_outline,
          title: 'Could not load your transactions',
          message: 'Something went wrong reading your finance data.',
          actionLabel: 'Retry',
          onAction: () =>
              ref.invalidate(watchTransactionsInRangeProvider(start, end)),
        ),
        data: (List<TransactionModel> transactions) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              SegmentedButton<_Range>(
                segments: const <ButtonSegment<_Range>>[
                  ButtonSegment<_Range>(value: _Range.week, label: Text('Week')),
                  ButtonSegment<_Range>(
                    value: _Range.month,
                    label: Text('Month'),
                  ),
                ],
                selected: <_Range>{_range},
                onSelectionChanged: (Set<_Range> selection) =>
                    setState(() => _range = selection.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              VWCard(child: _Chart(buckets: _buckets(transactions, _range))),
              const SizedBox(height: AppSpacing.lg),
              VWCard(child: _Breakdown(expenses: _expenses(transactions))),
            ],
          );
        },
      ),
    );
  }

  /// Half-open `[start, end)` bounds of the selected period. The end is the day
  /// after the period closes so `dateBetween` (inclusive) covers the last day.
  (DateTime, DateTime) _bounds(_Range range) {
    final DateTime now = DateTime.now();
    if (range == _Range.week) {
      final DateTime start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      return (start, start.add(const Duration(days: 7)));
    }
    return (
      DateTime(now.year, now.month),
      DateTime(now.year, now.month + 1, 1),
    );
  }

  List<_Bucket> _buckets(List<TransactionModel> transactions, _Range range) {
    if (range == _Range.week) {
      final DateTime now = DateTime.now();
      final DateTime start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final List<_Bucket> buckets = List<_Bucket>.generate(
        7,
        (int i) => _Bucket(label: _weekdayLabel(start.add(Duration(days: i)))),
      );
      for (final TransactionModel t in transactions) {
        final int index = DateTime(t.date.year, t.date.month, t.date.day)
            .difference(start)
            .inDays;
        if (index >= 0 && index < buckets.length) {
          buckets[index].add(t);
        }
      }
      return buckets;
    }

    final DateTime now = DateTime.now();
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int weekCount = ((daysInMonth - 1) ~/ 7) + 1;
    final List<_Bucket> buckets = List<_Bucket>.generate(
      weekCount,
      (int i) => _Bucket(label: 'W${i + 1}'),
    );
    for (final TransactionModel t in transactions) {
      final int week = (t.date.day - 1) ~/ 7;
      if (week >= 0 && week < buckets.length) {
        buckets[week].add(t);
      }
    }
    return buckets;
  }

  List<TransactionModel> _expenses(List<TransactionModel> transactions) =>
      transactions
          .where((TransactionModel t) => t.type == TransactionType.expense)
          .toList();

  String _weekdayLabel(DateTime date) =>
      const <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
}

class _Bucket {
  _Bucket({required this.label});

  final String label;
  double income = 0;
  double expense = 0;

  void add(TransactionModel transaction) {
    if (transaction.type == TransactionType.income) {
      income += transaction.amount;
    } else {
      expense += transaction.amount;
    }
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.buckets});

  final List<_Bucket> buckets;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxValue = buckets.fold<double>(
      0,
      (double acc, _Bucket b) => math.max(acc, math.max(b.income, b.expense)),
    );
    final double maxY = maxValue <= 0 ? 1 : maxValue * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const VWSectionHeader(title: 'Income vs. expense'),
        const SizedBox(height: AppSpacing.sm),
        const _ChartLegend(),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: const BarTouchData(enabled: false),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= buckets.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          buckets[index].label,
                          style: theme.textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: <BarChartGroupData>[
                for (int i = 0; i < buckets.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: buckets[i].income,
                        color: AppColors.incomeFor(theme.brightness),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: buckets[i].expense,
                        color: AppColors.expenseFor(theme.brightness),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Row(
      children: <Widget>[
        _LegendDot(color: AppColors.incomeFor(brightness), label: 'Income'),
        const SizedBox(width: AppSpacing.lg),
        _LegendDot(color: AppColors.expenseFor(brightness), label: 'Expense'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.expenses});

  final List<TransactionModel> expenses;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double total = expenses.fold<double>(
      0,
      (double acc, TransactionModel t) => acc + t.amount,
    );
    final List<CategoryTotal> totals = categoryTotals(expenses);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const VWSectionHeader(title: 'Spending by category'),
        const SizedBox(height: AppSpacing.md),
        if (totals.isEmpty)
          Text(
            'No expenses in this period.',
            style: theme.textTheme.bodyMedium,
          )
        else
          // The ring answers "how did it split up?" in one glance; the rows
          // answer "how much, exactly?". Both read the same `totals`, so they
          // cannot disagree (plan2.md P10-FIN-3).
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CategoryRing(totals: totals),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final CategoryTotal entry in totals)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: _BreakdownRow(
                          name: entry.name,
                          amount: entry.amount,
                          total: total,
                          color: AppColors.tagFor(
                            entry.tag,
                            theme.brightness,
                          ).foreground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.name,
    required this.amount,
    required this.total,
    required this.color,
  });

  final String name;
  final double amount;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double fraction = total <= 0 ? 0 : amount / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
            Text(
              '${formatMoney(amount)}  (${(fraction * 100).round()}%)',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
