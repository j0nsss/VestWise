import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_skeleton.dart';

/// A loading stand-in for one `NoteListTile` (plan2.md P11-T1).
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
    return const ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: SizedBox(
        width: 24,
        height: 24,
        child: VWSkeleton(width: 24, height: 24),
      ),
      title: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.6,
        child: VWSkeleton(height: 22),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Two abutting bars, because the real preview is one two-line Text.
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
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.35,
            child: VWSkeleton(height: 14),
          ),
        ],
      ),
      // The pin button: 48px of tap target around a 20px glyph.
      trailing: SizedBox(
        width: 48,
        height: 48,
        child: Center(child: VWSkeleton(width: 20, height: 20)),
      ),
    );
  }
}
