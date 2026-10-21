import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

/// A loading stand-in for one `NoteListTile` (plan2.md P11-T1, retargeted
/// Phase 14).
///
/// A note row is the tallest of the four list rows on purpose — title, up to
/// two preview lines and the edited time — so the placeholder copies that shape
/// instead of being a generic two-line bar. Heights are the line heights of the
/// roles they replace: `bodyLarge` ≈ 22, two `bodyMedium` lines ≈ 20 each,
/// `labelSmall` ≈ 14.
class NoteCardSkeleton extends StatelessWidget {
  const NoteCardSkeleton({super.key});

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.6,
                      child: VWSkeleton(height: 22),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // Two abutting bars, because the real preview is one
                    // two-line Text.
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.9,
                      child: VWSkeleton(height: 20),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.75,
                      child: VWSkeleton(height: 20),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.35,
                      child: VWSkeleton(height: 14),
                    ),
                  ],
                ),
              ),
              // The pin button: its 20px glyph in a 48px slot.
              SizedBox(
                width: 48,
                height: 48,
                child: Center(child: VWSkeleton(width: 20, height: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
