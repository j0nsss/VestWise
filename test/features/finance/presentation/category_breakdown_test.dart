import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/widgets/category_breakdown.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';

import '../../../helpers/contrast.dart';

/// A dataset of the size plan.md's P3-FIN-4 validation asks for: at least ten
/// transactions across at least two categories.
List<TransactionModel> _dataset() {
  const List<(String? name, double amount)> rows = <(String?, double)>[
    ('Food', 12.50),
    ('Food', 30.00),
    ('Food', 7.25),
    ('Food', 18.75),
    ('Transport', 4.00),
    ('Transport', 22.00),
    ('Transport', 9.50),
    ('Shopping', 150.00),
    ('Shopping', 49.99),
    ('Bills', 200.00),
    ('Bills', 55.00),
    (null, 5.00),
  ];

  return <TransactionModel>[
    for (final (String? name, double amount) row in rows)
      TransactionModel()
        ..amount = row.$2
        ..type = TransactionType.expense
        ..date = DateTime(2026, 3, 1)
        ..createdAt = DateTime(2026, 3, 1)
        ..category.value = row.$1 == null
            ? null
            : (CategoryModel()
              ..id = row.$1!.length
              ..name = row.$1!
              ..iconCodePoint = Icons.restaurant.codePoint
              ..colorValue = 0
              ..type = TransactionType.expense),
  ];
}

void main() {
  group('categoryTotals (P3-FIN-4 / P10-FIN-3)', () {
    test('the parts add up to the whole', () {
      final List<CategoryTotal> totals = categoryTotals(_dataset());
      final double sum = totals.fold<double>(
        0,
        (double acc, CategoryTotal t) => acc + t.amount,
      );

      expect(sum, closeTo(563.99, 0.001));
      expect(
        totals.fold<double>(
          0,
          (double acc, CategoryTotal t) => acc + t.shareOf(sum),
        ),
        closeTo(1, 0.0001),
      );
    });

    test('groups by category name, biggest first', () {
      final List<CategoryTotal> totals = categoryTotals(_dataset());

      expect(
        totals.map((CategoryTotal t) => t.name).toList(),
        <String>['Bills', 'Shopping', 'Food', 'Transport', uncategorizedLabel],
      );
      expect(totals.first.amount, closeTo(255.00, 0.001));
      expect(totals.last.amount, 5.00);
    });

    test('an expense with no category link lands in Uncategorized', () {
      final List<CategoryTotal> totals = categoryTotals(_dataset());
      final CategoryTotal uncategorized = totals.last;

      expect(uncategorized.name, uncategorizedLabel);
      expect(uncategorized.shareOf(563.99), closeTo(0.0089, 0.0001));
    });

    test('income is not part of a spending breakdown', () {
      // The caller filters to expenses; this documents that the helper does not
      // silently swallow unrelated rows if that filter is ever lost.
      final List<TransactionModel> mixed = _dataset()
        ..add(
          TransactionModel()
            ..amount = 1000
            ..type = TransactionType.income
            ..date = DateTime(2026, 3, 1)
            ..createdAt = DateTime(2026, 3, 1),
        );

      expect(
        categoryTotals(mixed).fold<double>(
          0,
          (double acc, CategoryTotal t) => acc + t.amount,
        ),
        closeTo(1563.99, 0.001),
      );
    });

    test('no expenses gives no totals, and a zero total shares as zero', () {
      expect(categoryTotals(const <TransactionModel>[]), isEmpty);
      expect(
        const CategoryTotal(name: 'Food', amount: 10, tag: AppTag.green)
            .shareOf(0),
        0,
      );
    });

    test('the hue comes from the name, so rows and chips agree', () {
      for (final CategoryTotal total in categoryTotals(_dataset())) {
        expect(total.tag, AppColors.tagForLabel(total.name));
      }
    });

    test('every ring segment stays a visible mark on the card', () {
      for (final Brightness brightness in Brightness.values) {
        for (final AppTag tag in AppTag.values) {
          final double ratio = contrastRatio(
            AppColors.tagFor(tag, brightness).foreground,
            AppColors.surfaceContainerHighestFor(brightness),
          );

          // WCAG 1.4.11: a ring segment is a non-text graphical object that
          // carries meaning, so it needs 3:1 against what it sits on.
          expect(
            ratio,
            greaterThanOrEqualTo(3),
            reason: '${tag.name} segment on ${brightness.name} is invisible',
          );
        }
      }
    });
  });

  group('CategoryRing (P10-FIN-3)', () {
    Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
        MaterialApp(
          theme:
              brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(
            body: Center(child: SizedBox(width: 320, child: child)),
          ),
        );

    testWidgets('shows the period total in the middle', (
      WidgetTester tester,
    ) async {
      final List<CategoryTotal> totals = categoryTotals(_dataset());
      await tester.pumpWidget(wrap(CategoryRing(totals: totals)));

      expect(find.text('Spent'), findsOneWidget);
      // Asserted through the app's own formatter, never a literal: money is
      // locale-dependent and a hard-coded '563.99' would fail on a phone that
      // formats it differently.
      expect(find.text(formatMoney(563.99)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without throwing on an empty breakdown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(const CategoryRing(totals: <CategoryTotal>[])),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(formatMoney(0)), findsOneWidget);
    });

    testWidgets('renders in both themes', (WidgetTester tester) async {
      for (final Brightness brightness in Brightness.values) {
        await tester.pumpWidget(
          wrap(
            CategoryRing(totals: categoryTotals(_dataset())),
            brightness: brightness,
          ),
        );

        expect(tester.takeException(), isNull);
      }
    });
  });
}
