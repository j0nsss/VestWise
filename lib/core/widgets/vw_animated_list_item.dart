import 'dart:async';

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
  const VWAnimatedListItem({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  /// Rows with an index at or above this are rendered statically.
  static const int visibleCount = 8;

  final Widget child;

  /// How long to wait before starting this row's entrance. Used by
  /// [VWStaggeredList] to cascade the first few rows (plan2.md P9-T2).
  final Duration delay;

  /// Whether the row at [index] should animate at all.
  ///
  /// This used to read "rows animate concurrently rather than on a stagger —
  /// a stagger would push the last one past the 250ms budget". That is still
  /// true of [maxDuration], but plan2.md P9-T1 documents one deliberate
  /// exception: [AppMotion.signature] (320ms) exists precisely so a capped
  /// stagger (180ms + 5 × 24ms = 300ms) fits. The stagger is therefore allowed
  /// — but only through [VWStaggeredList], and only because
  /// [AppMotion.staggerMaxItems] keeps the cascade inside that budget. Do not
  /// raise the cap; it is the thing holding the whole thing under 320ms.
  static bool animates(int index) => index < visibleCount;

  @override
  State<VWAnimatedListItem> createState() => _VWAnimatedListItemState();
}

class _VWAnimatedListItemState extends State<VWAnimatedListItem> {
  bool _visible = false;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      // One frame later, so the fade/slide is actually observed.
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    } else {
      _delayTimer = Timer(widget.delay, _show);
    }
  }

  void _show() {
    if (mounted && !_visible) {
      setState(() => _visible = true);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
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
