import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

/// A loading stand-in for one `EventListTile` (plan2.md P11-T1).
///
/// Copies that card's own structure — the accent bar reaching the rounded edge,
/// then the title and time column with the same padding and gap — so the day
/// list keeps its card rhythm while it loads. Bar heights are the roles they
/// replace: `titleSmall` ≈ 18, `bodySmall` ≈ 17.
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const VWCard(
      variant: VWCardVariant.flat,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Null height: stretched to the card's own height, exactly like the
            // real accent bar.
            VWSkeleton(width: 4, radius: 0),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.5,
                      child: VWSkeleton(height: 18),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.25,
                      child: VWSkeleton(height: 17),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
