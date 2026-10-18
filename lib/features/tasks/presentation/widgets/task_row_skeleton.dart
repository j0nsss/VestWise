import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

/// A loading stand-in for one `TaskListTile` (plan2.md P11-T1).
///
/// Built as the same two-line [ListTile] the real row uses, with the checkbox's
/// footprint, the title line and the priority/due row in their real slots. Each
/// bar is the line height of the type role it replaces — `bodyLarge` (16 × 1.4
/// ≈ 22) for the title, `labelSmall` (11 × 1.25 ≈ 14) for the meta row — so the
/// row is the height it will be, and the list does not jump when data lands.
class TaskRowSkeleton extends StatelessWidget {
  const TaskRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      // A checkbox is 48px of tap target around a 24px box; both numbers are
      // mirrored so the row's own height maths comes out the same.
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Center(child: VWSkeleton(width: 24, height: 24)),
      ),
      title: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.55,
        child: VWSkeleton(height: 22),
      ),
      subtitle: Row(
        children: <Widget>[
          VWSkeleton(width: 40, height: 14),
          SizedBox(width: AppSpacing.sm),
          VWSkeleton(width: 64, height: 14),
        ],
      ),
    );
  }
}
