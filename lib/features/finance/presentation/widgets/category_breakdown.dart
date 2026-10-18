import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';

/// One category's total spend over a period, and how it is coloured.
///
/// The hue is derived from the name via [AppColors.tagForLabel] rather than
/// taken from the stored ARGB value, so the ring, the row bar and the category
/// chip in the transaction list all agree on what "Food" looks like.
class CategoryTotal {
  const CategoryTotal({
    required this.name,
    required this.amount,
    required this.tag,
  });

  final String name;
  final double amount;
  final AppTag tag;

  double shareOf(double total) => total <= 0 ? 0 : amount / total;
}

/// Groups [expenses] by category, biggest first (plan.md P3-FIN-4).
///
/// Pure, so the sums can be checked against the raw transactions instead of
/// against a screenshot.
List<CategoryTotal> categoryTotals(List<TransactionModel> expenses) {
  final Map<String, double> byName = <String, double>{};

  for (final TransactionModel expense in expenses) {
    final CategoryModel? category = expense.category.value;
    final String name = category?.name ?? uncategorizedLabel;
    byName[name] = (byName[name] ?? 0) + expense.amount;
  }

  final List<CategoryTotal> totals = <CategoryTotal>[
    for (final MapEntry<String, double> entry in byName.entries)
      CategoryTotal(
        name: entry.key,
        amount: entry.value,
        tag: AppColors.tagForLabel(entry.key),
      ),
  ]..sort((CategoryTotal a, CategoryTotal b) => b.amount.compareTo(a.amount));

  return totals;
}

/// The label used for expenses whose category link is missing.
const String uncategorizedLabel = 'Uncategorized';

/// A compact donut of [totals] with the period's spend in the middle
/// (plan2.md P10-FIN-3).
///
/// `fl_chart` was already in the project for the bar chart, so this adds a chart
/// type, not a dependency.
class CategoryRing extends StatelessWidget {
  const CategoryRing({required this.totals, this.diameter = 132, super.key});

  final List<CategoryTotal> totals;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double total = totals.fold<double>(
      0,
      (double acc, CategoryTotal t) => acc + t.amount,
    );

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              // A hole, not a pie: the centre holds the total, which is the
              // number a ring is actually good at communicating.
              centerSpaceRadius: diameter * 0.31,
              startDegreeOffset: -90,
              sections: <PieChartSectionData>[
                for (final CategoryTotal entry in totals)
                  PieChartSectionData(
                    value: entry.amount,
                    color: AppColors.tagFor(
                      entry.tag,
                      theme.brightness,
                    ).foreground,
                    radius: diameter * 0.19,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Spent',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatMoney(total),
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
