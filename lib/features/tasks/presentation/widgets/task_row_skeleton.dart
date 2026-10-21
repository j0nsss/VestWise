import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

/// A loading stand-in for one `TaskListTile` (plan2.md P11-T1, retargeted
/// Phase 14).
///
/// Mirrors the real card exactly — same margins, same radius tier, same inner
/// padding, checkbox square, tag pill, title line and subtask pill in their
/// real slots — so the row is the height it will be and the list does not jump
/// when data lands.
class TaskRowSkeleton extends StatelessWidget {
  const TaskRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        vwPageMargin,
        0,
        vwPageMargin,
        AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // One hair darker than the real `surfaceContainer` card, so the
          // placeholder reads as the list "breathing" while it loads.
          color: AppColors.surfaceContainerHighestFor(
            Theme.of(context).brightness,
          ),
          borderRadius: AppRadii.row,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // The checkbox square, in its slot.
              VWSkeleton(width: 24, height: 24, radius: 6),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Priority pill + due text.
                    Row(
                      children: <Widget>[
                        VWSkeleton(width: 56, height: 18, radius: 9),
                        Spacer(),
                        VWSkeleton(width: 88, height: 14),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // The title line.
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.72,
                      child: VWSkeleton(height: 24),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // The subtask pill.
                    VWSkeleton(width: 96, height: 20, radius: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
