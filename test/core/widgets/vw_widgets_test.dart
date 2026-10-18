import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_section_header.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('VWCard renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const VWCard(child: Text('inside'))));
    expect(find.text('inside'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  group('VWCard variants (P8-T4)', () {
    testWidgets('flat is the default and inherits the flat theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const VWCard(child: Text('flat'))));

      final Card card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNull);
      expect(card.shape, isNull);
      expect(card.elevation, isNull);

      final CardThemeData theme = AppTheme.light.cardTheme;
      expect(theme.elevation, AppElevation.flat);
      expect(
        (theme.shape! as RoundedRectangleBorder).side.width,
        1,
        reason: 'flat cards are separated by a hairline border',
      );
    });

    testWidgets('soft drops the border and sits on the soft surface', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const VWCard(variant: VWCardVariant.soft, child: Text('soft'))),
      );

      final Card card = tester.widget<Card>(find.byType(Card));
      expect(card.color, AppColors.surfaceSoftFor(Brightness.light));
      expect(card.elevation, AppElevation.flat);
      expect((card.shape! as RoundedRectangleBorder).side, BorderSide.none);
    });

    testWidgets('elevated is the one card allowed to float', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const VWCard(variant: VWCardVariant.elevated, child: Text('high')),
        ),
      );

      final Card card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, AppElevation.overlay);
      expect(card.elevation, lessThanOrEqualTo(2));
      expect((card.shape! as RoundedRectangleBorder).side, BorderSide.none);
    });

    testWidgets('every variant keeps the card radius and renders the child', (
      WidgetTester tester,
    ) async {
      for (final VWCardVariant variant in VWCardVariant.values) {
        await tester.pumpWidget(
          _wrap(VWCard(variant: variant, child: Text(variant.name))),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.text(variant.name), findsOneWidget);

        final Card card = tester.widget<Card>(find.byType(Card));
        if (card.shape case final RoundedRectangleBorder shape) {
          expect(shape.borderRadius, AppRadii.card);
        }
      }
    });

    testWidgets('an interactive card renders a single tappable Card', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(VWCard(onTap: () => taps++, child: const Text('tap me'))),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.text('tap me'));
      expect(taps, 1);
    });
  });

  group('VWCard press feedback (P8-T4)', () {
    testWidgets('presses in on touch-down and springs back on release', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(VWCard(onTap: () {}, child: const Text('press'))),
      );

      double scale() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

      expect(scale(), 1.0);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.text('press')),
      );
      await tester.pump();
      expect(scale(), lessThan(1.0));

      await gesture.up();
      await tester.pump();
      expect(scale(), 1.0);

      await tester.pumpAndSettle();
    });

    testWidgets('the press animation stays inside the motion budget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(VWCard(onTap: () {}, child: const Text('press'))),
      );

      final AnimatedScale animated = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );
      expect(animated.duration, AppMotion.stateChange);
      expect(animated.duration, lessThanOrEqualTo(AppMotion.maxDuration));
    });

    testWidgets('reduced motion skips the press animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: VWCard(onTap: () {}, child: const Text('press')),
            ),
          ),
        ),
      );

      final AnimatedScale animated = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );
      expect(animated.duration, Duration.zero);
    });

    testWidgets('a non-interactive card has no press animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const VWCard(child: Text('static'))));

      expect(find.byType(AnimatedScale), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });
  });

  testWidgets('VWButton renders its label and fires onPressed', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      _wrap(VWButton(label: 'Save', onPressed: () => tapped = true)),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(tapped, isTrue);
  });

  testWidgets('VWButton variants and loading state render', (
    WidgetTester tester,
  ) async {
    for (final VWButtonVariant variant in VWButtonVariant.values) {
      await tester.pumpWidget(
        _wrap(VWButton(label: 'Go', variant: variant, onPressed: () {})),
      );
      expect(find.text('Go'), findsOneWidget);
    }

    await tester.pumpWidget(
      _wrap(const VWButton(label: 'Saving', isLoading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Saving'), findsNothing);
  });

  testWidgets('VWTextField shows label, hint and error text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const VWTextField(label: 'Amount', hint: '0.00', errorText: 'Required'),
      ),
    );

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('VWEmptyState shows message and optional CTA', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        VWEmptyState(
          message: 'No tasks yet',
          title: 'All clear',
          actionLabel: 'Add task',
          onAction: () {},
        ),
      ),
    );

    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('All clear'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
  });

  testWidgets('VWSectionHeader shows title and trailing action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        VWSectionHeader(
          title: 'Today',
          actionLabel: 'See all',
          onAction: () {},
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
  });

  testWidgets('VWAppBar shows its title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          appBar: VWAppBar(title: 'Tasks'),
          body: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Tasks'), findsOneWidget);
  });

  testWidgets('VWLoadingIndicator shows a spinner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const VWLoadingIndicator(message: 'Loading')),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
  });
}
