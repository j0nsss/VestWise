import 'package:flutter/material.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

/// A loading stand-in for one `TransactionListTile` (plan2.md P11-T1).
///
/// Same [ListTile] shape as the real row: the category chip, the note line, the
/// category line and the trailing amount. Bars are the line heights of the roles
/// they stand in for (`bodyLarge` ≈ 22, `bodyMedium` ≈ 20, `titleMedium` ≈ 21),
/// and the chip's 30×18 pill is copied from `VWCategoryChip`'s dense icon-only
/// form so the amounts arrive in the column they were already showing.
///
/// The real row drops its category line when the note and the category would
/// say the same thing, so a one-line row is one line shorter than its skeleton.
/// That is the only difference, and it is bounded by a single body-medium line.
class TransactionRowSkeleton extends StatelessWidget {
  const TransactionRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: VWSkeleton(width: 30, height: 18, radius: 9),
      title: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.45,
        child: VWSkeleton(height: 22),
      ),
      subtitle: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.3,
        child: VWSkeleton(height: 20),
      ),
      trailing: VWSkeleton(width: 64, height: 21),
    );
  }
}
