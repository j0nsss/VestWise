import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/widgets/icon_data_from_code_point.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/widgets/category_chip.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';

/// One row in the transaction history: category icon/color, note, and a signed
/// amount colored green for income / red for expense (plan P3-FIN-2).
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({required this.transaction, this.onTap, super.key});

  final TransactionModel transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CategoryModel? category = transaction.category.value;
    final IconData icon = category != null
        ? iconDataFromCodePoint(category.iconCodePoint)
        : Icons.receipt_long;

    final bool isIncome = transaction.type == TransactionType.income;
    final Color amountColor = isIncome
        ? AppColors.incomeFor(theme.brightness)
        : AppColors.expenseFor(theme.brightness);
    final String sign = isIncome ? '+' : '-';

    final String? note = transaction.note?.trim();
    final String title = (note != null && note.isNotEmpty)
        ? note
        : (category?.name ?? 'Transaction');

    return ListTile(
      onTap: onTap,
      // A contrast-checked tag pill rather than a hand-tinted circle: the old
      // avatar paired the stored ARGB colour with itself at 15% alpha, which
      // was never verified against anything (P10-FIN-1).
      leading: category != null
          ? CategoryChip(category: category, showLabel: false, dense: true)
          : CircleAvatar(
              backgroundColor:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
              child: Icon(
                icon,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: category != null && title != category.name
          ? Text(category.name)
          : null,
      trailing: Text(
        '$sign${formatMoney(transaction.amount)}',
        style: theme.textTheme.titleMedium?.copyWith(color: amountColor),
      ),
    );
  }
}
