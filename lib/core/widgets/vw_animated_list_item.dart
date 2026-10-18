import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_motion.dart';

/// Fades and slides a list row in the first time it is built (P5-T1).
///
/// Deliberately implicit: a one-shot animation on mount, no controller to
/// dispose. Combine it with a `ValueKey(item.id)` on the row so a *newly
/// inserted* item gets a fresh element (and therefore animates) while existing
/// rows keep their state and stay still.
///
/// Only the first [visibleCount] rows of a list should be wrapped: rows built
/// while scrolling must not animate, or a 200-item list would jank (P5-T5).
class VWAnimatedListItem extends StatefulWidget {
  const VWAnimatedListItem({required this.child, super.key});

  /// Rows with an index at or above this are rendered statically.
  static const int visibleCount = 8;

  final Widget child;

  /// Whether the row at [index] should animate at all. Every duration stays
  /// under `AppMotion.maxDuration`, so rows animate concurrently rather than on
  /// a stagger — a stagger would push the last one past the 250ms budget.
  static bool animates(int index) => index < visibleCount;

  @override
  State<VWAnimatedListItem> createState() => _VWAnimatedListItemState();
}

class _VWAnimatedListItemState extends State<VWAnimatedListItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // One frame later, so the fade/slide is actually observed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppMotion.listItemEnter,
      curve: AppMotion.enterCurve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: AppMotion.listItemEnter,
        curve: AppMotion.enterCurve,
        child: widget.child,
      ),
    );
  }
}
