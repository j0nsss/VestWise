import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/icon_data_from_code_point.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:vestwise/features/finance/presentation/widgets/category_chip.dart';

import '../../../helpers/contrast.dart';
import '../../../helpers/isar_test_harness.dart';

/// The seeded categories are the real thing a user sees on a fresh install, so
/// the chip is checked against them rather than against hand-written stubs
/// (plan2.md P10-FIN-1).
void main() {
  late IsarTestHarness harness;
  late List<CategoryModel> categories;

  setUpAll(() async {
    harness = await IsarTestHarness.create();
    final FinanceRepositoryImpl repo = FinanceRepositoryImpl(harness.isar);
    await repo.seedDefaultCategories();
    categories = (await repo.getAllCategories()).dataOrNull!;
  });

  tearDownAll(() => harness.dispose());

  test('the seeds are what we think they are', () {
    expect(categories, hasLength(12));
    expect(
      categories.map((CategoryModel c) => c.name),
      containsAll(<String>['Salary', 'Food', 'Health', 'Other']),
    );
    for (final CategoryModel category in categories) {
      expect(category.iconCodePoint, greaterThan(0));
    }
  });

  testWidgets('every seeded category renders, safely, in both themes', (
    WidgetTester tester,
  ) async {
    for (final Brightness brightness in Brightness.values) {
      for (final CategoryModel category in categories) {
        await tester.pumpWidget(
          MaterialApp(
            theme: brightness == Brightness.dark
                ? AppTheme.dark
                : AppTheme.light,
            home: Scaffold(
              body: Center(child: CategoryChip(category: category)),
            ),
          ),
        );

        expect(
          find.text(category.name),
          findsOneWidget,
          reason: '${category.name} did not render on ${brightness.name}',
        );

        final Icon icon = tester.widget<Icon>(
          find.byIcon(iconDataFromCodePoint(category.iconCodePoint)),
        );
        final Material pill = tester.widget<Material>(
          find
              .ancestor(
                of: find.text(category.name),
                matching: find.byType(Material),
              )
              .first,
        );

        // The whole point of dropping the stored ARGB colour: what is actually
        // painted is a pair that has been verified, not whatever was saved.
        expect(
          contrastRatio(icon.color!, pill.color!),
          greaterThanOrEqualTo(4.5),
          reason: '${category.name} is unreadable on ${brightness.name}',
        );
      }
    }
  });

  testWidgets('a category with no icon stored still renders (legacy rows)', (
    WidgetTester tester,
  ) async {
    // Existing notes/rows predate any chip; a missing or zero code point must
    // fall back to the neutral document icon rather than crash.
    final CategoryModel legacy = CategoryModel()
      ..name = 'Legacy'
      ..iconCodePoint = 0
      ..colorValue = Colors.grey.toARGB32()
      ..type = TransactionType.expense;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(child: CategoryChip(category: legacy)),
        ),
      ),
    );

    expect(find.text('Legacy'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byType(Icon)).icon,
      iconDataFromCodePoint(0),
      reason: 'code point 0 must map to a defined IconData, not throw',
    );
  });

  test('the seeded category names take several different hues', () {
    final Set<AppTag> hues = <AppTag>{
      for (final CategoryModel category in categories)
        AppColors.tagForLabel(category.name),
    };

    expect(
      hues.length,
      greaterThan(2),
      reason:
          'twelve categories collapsing to one or two colours would be a bug',
    );
  });
}
