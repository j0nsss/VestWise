import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/widgets/category_chip.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';

/// One row in the transaction history, as a Phase 13 card: the category
/// badge, the note as title, the category name as the muted meta line, and a
/// signed amount colored green for income / red for expense (plan P3-FIN-2).
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({required this.transaction, this.onTap, super.key});

  final TransactionModel transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CategoryModel? category = transaction.category.value;

    final bool isIncome = transaction.type == TransactionType.income;
    final Color amountColor = isIncome
        ? AppColors.incomeFor(theme.brightness)
        : AppColors.expenseFor(theme.brightness);
    final String sign = isIncome ? '+' : '-';

    final String? note = transaction.note?.trim();
    final String title = (note != null && note.isNotEmpty)
        ? note
        : (category?.name ?? 'Transaction');

    return Padding(
      // Card separated from its neighbours and from the screen edges, exactly
      // like the task list rows.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: AppRadii.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                // The contrast-checked category badge keeps the P10-FIN-1
                // treatment; only its slot changes.
                SizedBox(
                  width: 44,
                  child: Center(
                    child: category != null
                        ? CategoryChip(category: category, showLabel: false)
                        : Icon(
                            Icons.receipt_long,
                            color: scheme.onSurfaceVariant,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category !=null && title != category.name)
                        Text(
                          category.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$sign${formatMoney(transaction.amount)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
