import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_motion.dart';

/// Swaps content in place with a short cross-fade (plan2.md P9-T2).
///
/// For the "same slot, different thing" cases: a list becoming an empty state,
/// one tab's body replacing another, a summary card appearing after its data
/// loads. Key the child (e.g. `ValueKey(_Range.today)`) — [AnimatedSwitcher]
/// only cross-fades when the new child differs from the old one, and without a
/// key two same-typed children look identical to it.
///
/// Under reduced motion the switch is instant, not merely faster.
class VWFadeThrough extends StatelessWidget {
  const VWFadeThrough({
    required this.child,
    this.duration = AppMotion.stateChange,
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: motionDuration(context, duration),
      switchInCurve: AppMotion.standardCurve,
      switchOutCurve: AppMotion.standardCurve,
      child: child,
    );
  }
}
