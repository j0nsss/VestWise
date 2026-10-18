import 'package:flutter/widgets.dart';

/// Motion tokens (plan P5-T1).
///
/// VestWise is a "fast and minimal" app, not an effects showcase: every
/// animation is short, purposeful and bounded by [maxDuration]. Anything that
/// would need longer than ~250ms should not be animated at all.
abstract final class AppMotion {
  /// The ceiling every animation in the app must respect (P5-T1). Enforced by
  /// `test/core/constants/app_motion_test.dart`.
  static const Duration maxDuration = Duration(milliseconds: 250);

  /// Route-to-route page transition.
  static const Duration pageTransition = Duration(milliseconds: 200);

  /// A list row arriving on screen.
  static const Duration listItemEnter = Duration(milliseconds: 180);

  /// State feedback, e.g. a row collapsing into its completed styling.
  static const Duration stateChange = Duration(milliseconds: 150);

  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve standardCurve = Curves.easeInOut;
}

/// Whether the platform asks for reduced motion (Android "Remove animations",
/// iOS "Reduce Motion"). Honoured by skipping transitions outright rather than
/// merely shortening them — an accessibility requirement (P5-T3).
bool prefersReducedMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;
