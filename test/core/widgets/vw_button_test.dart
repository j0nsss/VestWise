import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_inline_spinner.dart';

Future<void> _pump(
  WidgetTester tester, {
  VWButtonVariant variant = VWButtonVariant.primary,
  bool isLoading = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: VWButton(
          label: 'Save',
          variant: variant,
          isLoading: isLoading,
          onPressed: () {},
        ),
      ),
    ),
  );
}

void main() {
  for (final VWButtonVariant variant in VWButtonVariant.values) {
    testWidgets('${variant.name} meets the 48px tap target (P5-T3)', (
      WidgetTester tester,
    ) async {
      await _pump(tester, variant: variant);

      expect(
        tester.getSize(find.byType(VWButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  }

  testWidgets('exposes its label to assistive technology', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(tester);

    expect(find.bySemanticsLabel('Save'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('shows the shared inline spinner while loading', (
    WidgetTester tester,
  ) async {
    await _pump(tester, isLoading: true);

    expect(find.byType(VWInlineSpinner), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  group('VWButton press feedback (P11-T4)', () {
    AnimatedScale animatedOf(WidgetTester tester) =>
        tester.widget<AnimatedScale>(
          find.descendant(
            of: find.byType(VWButton),
            matching: find.byType(AnimatedScale),
          ),
        );

    testWidgets('presses in on touch-down and springs back on release', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      expect(animatedOf(tester).scale, 1.0);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(VWButton)),
      );
      await tester.pump();
      expect(animatedOf(tester).scale, lessThan(1.0));

      await gesture.up();
      await tester.pump();
      expect(animatedOf(tester).scale, 1.0);

      await tester.pumpAndSettle();
    });

    testWidgets('the press animation stays inside the motion budget', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      expect(animatedOf(tester).duration, AppMotion.stateChange);
      expect(
        animatedOf(tester).duration,
        lessThanOrEqualTo(AppMotion.maxDuration),
      );
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
              body: VWButton(label: 'Save', onPressed: () {}),
            ),
          ),
        ),
      );

      expect(animatedOf(tester).duration, Duration.zero);
    });

    testWidgets('a disabled button does not react to a touch', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: VWButton(label: 'Save')),
        ),
      );

      expect(find.byType(AnimatedScale), findsNothing);
    });

    testWidgets('a loading button does not react to a touch', (
      WidgetTester tester,
    ) async {
      await _pump(tester, isLoading: true);

      expect(find.byType(AnimatedScale), findsNothing);
    });

    testWidgets('a button presses exactly like a card', (
      WidgetTester tester,
    ) async {
      // The point of P11-T4: one interaction language, not two.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: <Widget>[
                VWCard(onTap: () {}, child: const Text('card')),
                VWButton(label: 'Save', onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      final TestGesture onCard = await tester.startGesture(
        tester.getCenter(find.text('card')),
      );
      final TestGesture onButton = await tester.startGesture(
        tester.getCenter(find.byType(VWButton)),
      );
      await tester.pump();

      double scaleIn(Type type) => tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byType(type),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;

      expect(scaleIn(VWCard), AppMotion.pressedScale);
      expect(scaleIn(VWButton), scaleIn(VWCard));

      await onCard.up();
      await onButton.up();
      await tester.pumpAndSettle();
    });
  });
}
