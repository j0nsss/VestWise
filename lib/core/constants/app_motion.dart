import 'package:flutter/widgets.dart';

/// Motion tokens (plan P5-T1, extended in plan2.md P9-T1).
///
/// VestWise is a "fast and minimal" app, not an effects showcase: every
/// animation is short, purposeful and bounded by [maxDuration].
///
/// **Documented exception:** [signature] (320ms) deliberately exceeds that
/// ceiling. It is reserved for the two or three genuinely emphasized
/// interactions in the app — the task-complete morph and the swipe-reveal snap
/// — where a 250ms move would read as a twitch. Everything else uses the
/// sub-250ms tokens. Do not "fix" this by lowering [signature] to fit
/// [maxDuration]; the budget test in `app_motion_test.dart` encodes the
/// exception on purpose.
abstract final class AppMotion {
  /// The default ceiling every animation in the app must respect (P5-T1).
  /// Enforced by `test/core/constants/app_motion_test.dart`.
  static const Duration maxDuration = Duration(milliseconds: 250);

  /// Route-to-route page transition.
  static const Duration pageTransition = Duration(milliseconds: 200);

  /// A list row arriving on screen.
  static const Duration listItemEnter = Duration(milliseconds: 180);

  /// State feedback, e.g. a row collapsing into its completed styling.
  static const Duration stateChange = Duration(milliseconds: 150);

  /// The single emphasized duration (P9-T1) — see the class docs for why it is
  /// allowed past [maxDuration]. Nothing may exceed this.
  static const Duration signature = Duration(milliseconds: 320);

  /// Per-index delay for [VWStaggeredList]'s entrance, and the number of rows
  /// that may be staggered. Together they keep the whole cascade inside
  /// [signature]: `listItemEnter + staggerMaxItems × staggerStep` = 180 + 120 =
  /// 300ms ≤ 320ms. That is why the cap exists and why the delay is a token.
  static const Duration staggerStep = Duration(milliseconds: 24);
  static const int staggerMaxItems = 5;

  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve standardCurve = Curves.easeInOut;

  /// For "satisfying" moments: the task-complete checkmark, the swipe-reveal
  /// snap. A back-eased cubic — the `y1 > 1` control point gives a few percent
  /// of overshoot, which is what makes it feel spring-like without a physics
  /// package or a simulation that never quite settles.
  static const Curve curveEmphasized = Cubic(0.34, 1.3, 0.64, 1);
}

/// Whether the platform asks for reduced motion (Android "Remove animations",
/// iOS "Reduce Motion"). Honoured by skipping transitions outright rather than
/// merely shortening them — an accessibility requirement (P5-T3).
bool prefersReducedMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// [duration], or zero when reduced motion is on.
///
/// The single place that decision is made, so a new animation cannot quietly
/// forget the [prefersReducedMotion] check (P9-T1).
Duration motionDuration(BuildContext context, Duration duration) =>
    prefersReducedMotion(context) ? Duration.zero : duration;
