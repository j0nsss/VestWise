import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';

/// Wraps a task row in the two swipe gestures (plan P10-TASKS-3):
/// right-to-left deletes, left-to-right completes.
///
/// Built on `Dismissible` with `direction: horizontal` and a `confirmDismiss`
/// that branches on the swipe direction, so no new dependency is needed.
class SwipeableTaskRow extends StatelessWidget {
  const SwipeableTaskRow({
    required this.taskId,
    required this.child,
    required this.onSwipeComplete,
    required this.onSwipeDelete,
    super.key,
  });

  final int taskId;
  final Widget child;

  /// Swiping towards the end of the line completes the task.
  final VoidCallback onSwipeComplete;

  /// Swiping towards the start asks to delete it. The confirmation and the
  /// delete itself belong to the caller: this widget only recognises the
  /// gesture, so there is exactly one delete path in the feature.
  final Future<void> Function() onSwipeDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey<int>(taskId),
      direction: DismissDirection.horizontal,
      background: _SwipeAction(
        icon: Icons.check,
        background: scheme.primary,
        foreground: scheme.onPrimary,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeAction(
        icon: Icons.delete_outline,
        background: scheme.error,
        foreground: scheme.onError,
        alignment: Alignment.centerRight,
      ),
      // Always false, in both directions, and deliberately so: this list is
      // stream-driven, so the row must leave when the *write* lands, not when
      // the animation ends. Letting `Dismissible` complete its dismissal would
      // either fight the stream or trip Flutter's "a dismissed Dismissible is
      // still part of the tree" assertion, which fires whenever a list cannot
      // remove the row in the same frame the animation finishes.
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Not awaited: the tile plays the P9-T4 completion morph while the
          // row snaps back, and the stream re-groups it afterwards.
          onSwipeComplete();
        } else {
          unawaited(onSwipeDelete());
        }
        return false;
      },
      child: child,
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.alignment,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      // Decorative: the swipe itself is the affordance, and TalkBack reaches
      // both actions through the tile's own controls.
      child: ExcludeSemantics(
        child: Icon(icon, color: foreground),
      ),
    );
  }
}
