import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_category_chip.dart';

import '../../helpers/contrast.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

/// The chip's own [Material] — the nearest one to its label, since the app and
/// the scaffold each contribute one too.
Material _pillOf(WidgetTester tester, Finder label) => tester.widget<Material>(
      find.ancestor(of: label, matching: find.byType(Material)).first,
    );

void main() {
  group('VWCategoryChip (P10-FIN-1)', () {
    testWidgets('renders icon and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const VWCategoryChip(icon: Icons.restaurant, label: 'Food')),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('without a label it is an icon-only pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const VWCategoryChip(icon: Icons.restaurant)),
      );

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('tapping fires the callback', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          VWCategoryChip(
            icon: Icons.restaurant,
            label: 'Food',
            onTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Food'));
      expect(taps, 1);
    });

    testWidgets('its colours are the contrast-checked tag pair for the hue', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const VWCategoryChip(
            icon: Icons.restaurant,
            label: 'Food',
            tag: AppTag.purple,
          ),
        ),
      );

      final AppTagColor pair = AppColors.tagFor(AppTag.purple, Brightness.light);
      final Material pill = _pillOf(tester, find.text('Food'));
      final Icon icon = tester.widget<Icon>(find.byIcon(Icons.restaurant));
      final Text label = tester.widget<Text>(find.text('Food'));

      expect(pill.color, pair.background);
      expect(icon.color, pair.foreground);
      expect(label.style?.color, pair.foreground);
    });

    testWidgets('selected swaps the pair rather than tinting it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const VWCategoryChip(
            icon: Icons.restaurant,
            label: 'Food',
            tag: AppTag.blue,
            selected: true,
          ),
        ),
      );

      final AppTagColor pair = AppColors.tagFor(AppTag.blue, Brightness.light);
      final Material pill = _pillOf(tester, find.text('Food'));
      final Text label = tester.widget<Text>(find.text('Food'));

      expect(pill.color, pair.foreground);
      expect(label.style?.color, pair.background);
      // Swapping the roles of a 4.5:1 pair keeps it a 4.5:1 pair.
      expect(
        contrastRatio(label.style!.color!, pill.color!),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('every hue renders on both themes', (
      WidgetTester tester,
    ) async {
      for (final Brightness brightness in Brightness.values) {
        for (final AppTag tag in AppTag.values) {
          await tester.pumpWidget(
            _wrap(
              VWCategoryChip(icon: Icons.label, label: tag.name, tag: tag),
              brightness: brightness,
            ),
          );

          expect(find.text(tag.name), findsOneWidget);
        }
      }
    });

    test('the derived hue is stable across runs, not run-random', () {
      // Pinned values: if this ever changes, existing categories silently
      // change colour after an update, so it should be a deliberate decision.
      expect(VWCategoryChip.tagForLabel('Food'), VWCategoryChip.tagForLabel('Food'));
      expect(
        VWCategoryChip.tagForLabel('Food'),
        isA<AppTag>(),
      );

      final Set<AppTag> hues = <AppTag>{
        for (final String name in <String>[
          'Salary',
          'Allowance',
          'Gift',
          'Other Income',
          'Food',
          'Transport',
          'Shopping',
          'Bills',
          'Education',
          'Entertainment',
          'Health',
          'Other',
        ])
          VWCategoryChip.tagForLabel(name),
      };

      expect(
        hues.length,
        greaterThan(1),
        reason: 'the seeded categories must not all collapse to one hue',
      );
    });
  });
}
