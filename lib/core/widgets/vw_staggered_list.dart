import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/widgets/vw_animated_list_item.dart';

/// Cascades the first few rows of a list in (plan2.md P9-T2).
///
/// Wrap every row; this decides what that means. Rows past
/// [VWAnimatedListItem.visibleCount] are returned untouched, so a 200-item
/// transaction history is not asked to animate 200 times — the feature does not
/// have to remember that rule.
///
/// The cascade is deliberately tiny: [AppMotion.staggerStep] per row, for at
/// most [AppMotion.staggerMaxItems] steps, after which rows share the last
/// delay rather than queueing up. That is what keeps the slowest row inside
/// [AppMotion.signature] (180ms entrance + 120ms of delay = 300ms ≤ 320ms).
class VWStaggeredList extends StatelessWidget {
  const VWStaggeredList({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  /// The delay for the row at [index]: `index × staggerStep`, saturating at
  /// `staggerMaxItems × staggerStep`.
  static Duration delayFor(int index) {
    final int steps = index < AppMotion.staggerMaxItems
        ? index
        : AppMotion.staggerMaxItems;

    return Duration(milliseconds: AppMotion.staggerStep.inMilliseconds * steps);
  }

  @override
  Widget build(BuildContext context) {
    if (!VWAnimatedListItem.animates(index)) {
      return child;
    }

    return VWAnimatedListItem(delay: delayFor(index), child: child);
  }
}
