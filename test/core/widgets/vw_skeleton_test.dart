import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool reduceMotion = false,
  bool dark = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('VWSkeleton (P11-T1)', () {
    testWidgets('a bar takes the size it is given', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Center(child: VWSkeleton(width: 80, height: 12)),
      );

      expect(tester.getSize(find.byType(VWSkeleton)), const Size(80, 12));
    });

    testWidgets('the line shorthand is one text line tall', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const Center(child: VWSkeleton.line(width: 120)));

      final Size size = tester.getSize(find.byType(VWSkeleton));
      expect(size.width, 120);
      expect(
        size.height,
        12,
        reason: 'the same height as the body line it stands in for',
      );
    });

    testWidgets('the tint comes from the theme, not a literal', (
      WidgetTester tester,
    ) async {
      for (final bool dark in <bool>[false, true]) {
        await _pump(
          tester,
          const Center(child: VWSkeleton(width: 40, height: 12)),
          dark: dark,
        );

        final BuildContext context = tester.element(find.byType(VWSkeleton));
        final Container container = tester.widget<Container>(
          find.descendant(
            of: find.byType(VWSkeleton),
            matching: find.byType(Container),
          ),
        );
        final BoxDecoration decoration = container.decoration! as BoxDecoration;

        expect(
          decoration.color,
          Theme.of(context).colorScheme.surfaceContainerHighest,
          reason: 'dark=$dark',
        );
      }
    });
  });

  group('VWShimmer (P11-T1)', () {
    testWidgets('sweeps a highlight across its children', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Center(
          child: VWShimmer(child: VWSkeleton(width: 100, height: 12)),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);

      // A sweeping gradient cannot be settled to a stop, so the assertion is
      // that the painted shader actually changes frame to frame.
      final ShaderMask before = tester.widget<ShaderMask>(
        find.byType(ShaderMask),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final ShaderMask after = tester.widget<ShaderMask>(
        find.byType(ShaderMask),
      );

      const Rect bounds = Rect.fromLTWH(0, 0, 100, 12);
      expect(
        before.shaderCallback(bounds),
        isNot(after.shaderCallback(bounds)),
      );
    });

    testWidgets('reduced motion freezes it to a static tint', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Center(
          child: VWShimmer(child: VWSkeleton(width: 100, height: 12)),
        ),
        reduceMotion: true,
      );

      expect(
        find.byType(ShaderMask),
        findsNothing,
        reason: 'no sweep at all, rather than a slower one',
      );
      expect(find.byType(VWSkeleton), findsOneWidget);

      // And nothing is left ticking behind it.
      await tester.pump(const Duration(seconds: 2));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a whole row sweeps under one controller', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Center(
          child: VWShimmer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                VWSkeleton(width: 100, height: 12),
                SizedBox(height: 8),
                VWSkeleton(width: 60, height: 12),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(VWSkeleton), findsNWidgets(2));
      expect(
        find.byType(ShaderMask),
        findsOneWidget,
        reason: 'one mask for the row, not one per bar',
      );
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
