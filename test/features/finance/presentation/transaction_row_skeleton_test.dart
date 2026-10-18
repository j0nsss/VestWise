import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_list_tile.dart';
import 'package:vestwise/features/finance/presentation/widgets/transaction_row_skeleton.dart';

import '../../../helpers/scroll_contexts.dart';

TransactionModel _transaction() => TransactionModel()
  ..amount = 12.5
  ..type = TransactionType.expense
  ..date = DateTime(2026, 3, 1)
  ..createdAt = DateTime(2026, 3, 1)
  ..note = 'Lunch'
  ..category.value = (CategoryModel()
    ..id = 1
    ..name = 'Food'
    ..iconCodePoint = Icons.restaurant.codePoint
    ..colorValue = 0
    ..type = TransactionType.expense);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  ),
);

void main() {
  group('TransactionRowSkeleton (P11-T1)', () {
    testWidgets('occupies the same row the real transaction will', (
      WidgetTester tester,
    ) async {
      await _pump(tester, TransactionListTile(transaction: _transaction()));
      final double real = tester
          .getSize(find.byType(TransactionListTile))
          .height;

      await _pump(tester, const TransactionRowSkeleton());
      final double skeleton = tester
          .getSize(find.byType(TransactionRowSkeleton))
          .height;

      expect(
        (real - skeleton).abs(),
        lessThanOrEqualTo(3),
        reason: 'real $real vs skeleton $skeleton',
      );
    });

    testWidgets('survives the scroll contexts that bit this project once', (
      WidgetTester tester,
    ) async {
      await expectSurvivesScrollContexts(
        tester,
        const TransactionRowSkeleton(),
        TransactionRowSkeleton,
      );
    });
  });
}
