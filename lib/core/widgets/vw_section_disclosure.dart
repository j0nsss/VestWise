import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_spacing.dart';

/// A collapsible group heading: a chevron that rotates over the standard
/// state-change duration (instant under reduced motion), the group's name and
/// its count.
///
/// Shared by the notes list (Pinned/Others, plan2.md P10-NOTES-3) and the task
/// list (Today/Upcoming/…, P10-TASKS-1). Collapse state is *not* owned here —
/// callers hold it, and both callers hold it in memory only.
class VWSectionDisclosure extends StatelessWidget {
  const VWSectionDisclosure({
    required this.label,
    required this.count,
    required this.unit,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  final String label;
  final int count;

  /// Singular noun for [count] ("note", "task"); pluralised for screen readers.
  final String unit;

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final String spokenCount = count == 1 ? '1 $unit' : '$count ${unit}s';

    return Semantics(
      button: true,
      expanded: expanded,
      label: '$label, $spokenCount',
      // The visible text is already in [label]; without this the count would be
      // announced twice.
      excludeSemantics: true,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              AnimatedRotation(
                turns: expanded ? 0 : -0.25,
                duration: motionDuration(context, AppMotion.stateChange),
                child: Icon(Icons.expand_more, size: 20, color: muted),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$label · $count',
                style: theme.textTheme.labelLarge?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
