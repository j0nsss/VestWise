import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_motion.dart';

void main() {
  test('every motion token stays inside the ~250ms budget (P5-T1)', () {
    const Map<String, Duration> tokens = <String, Duration>{
      'pageTransition': AppMotion.pageTransition,
      'listItemEnter': AppMotion.listItemEnter,
      'stateChange': AppMotion.stateChange,
      'staggerStep': AppMotion.staggerStep,
    };

    for (final MapEntry<String, Duration> token in tokens.entries) {
      expect(
        token.value.inMilliseconds,
        greaterThan(0),
        reason: '${token.key} must animate',
      );
      expect(
        token.value.inMilliseconds,
        lessThanOrEqualTo(AppMotion.maxDuration.inMilliseconds),
        reason:
            '${token.key} exceeds the ${AppMotion.maxDuration.inMilliseconds}ms budget',
      );
    }
  });

  test('signature is the one documented exception, capped at 400ms (P9-T1)', () {
    // plan2.md §5 P9-T1: `signature` is deliberately longer than `maxDuration`
    // so the task-complete morph and swipe-reveal snap can land. The ceiling
    // for it is 400ms — if this ever needs raising, the motion language has
    // been lost and the exception should be re-argued, not silently widened.
    expect(AppMotion.signature, greaterThan(AppMotion.maxDuration));
    expect(AppMotion.signature.inMilliseconds, lessThanOrEqualTo(400));

    // Everything else still obeys the default budget.
    for (final Duration token in <Duration>[
      AppMotion.pageTransition,
      AppMotion.listItemEnter,
      AppMotion.stateChange,
      AppMotion.staggerStep,
    ]) {
      expect(token, lessThanOrEqualTo(AppMotion.maxDuration));
    }
  });

  test('the skeleton sweep is a loop, and exempt by category (P11-T1)', () {
    // Outside the transition budget on purpose: a transition moves once when
    // something happens, a loading sweep loops until the data arrives, and a
    // sub-250ms loop reads as flicker. The exemption is banded and explicit
    // here rather than left implicit by simply not listing the token.
    expect(AppMotion.skeletonSweep, greaterThan(AppMotion.maxDuration));
    expect(AppMotion.skeletonSweep.inMilliseconds, inInclusiveRange(800, 2000));
  });

  test('the staggered cascade fits inside signature (P9-T1)', () {
    final int cascade =
        AppMotion.listItemEnter.inMilliseconds +
        AppMotion.staggerMaxItems * AppMotion.staggerStep.inMilliseconds;

    expect(
      AppMotion.staggerMaxItems,
      5,
      reason: 'the cap is what keeps the cascade inside the budget',
    );
    expect(cascade, lessThanOrEqualTo(AppMotion.signature.inMilliseconds));
  });

  test('curveEmphasized overshoots gently and still ends at 1 (P9-T1)', () {
    expect(AppMotion.curveEmphasized, isNot(AppMotion.standardCurve));
    expect(AppMotion.curveEmphasized.transform(0), 0);
    expect(AppMotion.curveEmphasized.transform(1), closeTo(1, 0.001));

    double peak = 0;
    for (int i = 0; i <= 100; i++) {
      peak = peak > AppMotion.curveEmphasized.transform(i / 100)
          ? peak
          : AppMotion.curveEmphasized.transform(i / 100);
    }

    expect(peak, greaterThan(1), reason: 'the emphasized curve has snap');
    expect(peak, lessThan(1.15), reason: 'but it must not turn into a bounce');
  });

  group('reduced motion short-circuits the new tokens too (P9-T1)', () {
    Widget harness({required bool reduce, required Widget child}) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: child,
    );

    testWidgets('motionDuration collapses to zero when asked', (
      WidgetTester tester,
    ) async {
      late BuildContext reduced;
      late BuildContext normal;

      await tester.pumpWidget(
        harness(
          reduce: true,
          child: Builder(
            builder: (BuildContext context) {
              reduced = context;
              return harness(
                reduce: false,
                child: Builder(
                  builder: (BuildContext context) {
                    normal = context;
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(prefersReducedMotion(reduced), isTrue);
      expect(motionDuration(reduced, AppMotion.signature), Duration.zero);
      expect(motionDuration(reduced, AppMotion.pageTransition), Duration.zero);

      expect(prefersReducedMotion(normal), isFalse);
      expect(motionDuration(normal, AppMotion.signature), AppMotion.signature);
    });
  });
}
