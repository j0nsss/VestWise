import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';

/// Base container for card-based layouts (plan P1-T6). Styling (radius, border,
/// background) comes from the theme so features never define their own.
class VWCard extends StatelessWidget {
  const VWCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(padding: padding, child: child);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: AppRadii.card,
              child: content,
            ),
    );
  }
}
