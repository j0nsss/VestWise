import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

/// A loading stand-in for one `TransactionListTile` (plan2.md P11-T1,
/// retargeted Phase 14).
///
/// Mirrors the real card — same margins, same radius tier, same inner padding,
/// category badge square, title line, category line and amount in their real
/// slots — so the row is the height it will be and the list does not jump when
/// data lands.
class TransactionRowSkeleton extends StatelessWidget {
  const TransactionRowSkeleton({super.key});

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
          // One hair darker than the real `surfaceContainerHigh` row, so the
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
            children: <Widget>[
              // The category badge square.
              VWSkeleton(width: 40, height: 40, radius: 12),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // The note (title) line.
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.5,
                      child: VWSkeleton(height: 20),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // The category line, skipped by the real row when the note
                    // and category say the same thing — bounded by one line.
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.3,
                      child: VWSkeleton(height: 16),
                    ),
                  ],
                ),
              ),
              // The amount.
              VWSkeleton(width: 72, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
