import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';

/// A category (or any tag) as a soft pill (plan2.md P10-FIN-1).
///
/// Colours come from [AppColors.tagFor], not from any stored per-category
/// colour: the pairs are contrast-checked as a set, whereas an arbitrary
/// persisted ARGB value can land anywhere on the wheel and is nobody's job to
/// verify. When [tag] is omitted the hue is derived from [label] with a stable
/// hash, so a category keeps the same colour across restarts without anyone
/// having to store it.
///
/// With no [label] it degrades to an icon-only pill, which is what list rows
/// use in place of a plain tinted circle.
class VWCategoryChip extends StatelessWidget {
  const VWCategoryChip({
    required this.icon,
    this.label,
    this.tag,
    this.onTap,
    this.selected = false,
    this.dense = false,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final String? label;

  /// Overrides the derived hue. Used by callers that want a specific colour
  /// (e.g. a priority chip), not usually by categories.
  final AppTag? tag;

  final VoidCallback? onTap;
  final bool selected;

  /// Tighter padding for list rows.
  final bool dense;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final AppTagColor pair = AppColors.tagFor(
      tag ?? AppColors.tagForLabel(label ?? icon.codePoint.toString()),
      brightness,
    );

    // Selected inverts the pair rather than tinting it, so the foreground and
    // background simply swap roles — a 4.5:1 pair stays a 4.5:1 pair.
    final Color background = selected ? pair.foreground : pair.background;
    final Color foreground = selected ? pair.background : pair.foreground;

    final double gap = dense ? AppSpacing.xs : AppSpacing.sm;
    final EdgeInsetsGeometry padding = EdgeInsets.symmetric(
      horizontal: dense ? AppSpacing.sm : AppSpacing.md,
      vertical: dense ? 2 : AppSpacing.xs,
    );

    return Semantics(
      label: semanticLabel ?? label,
      button: onTap != null,
      selected: onTap != null ? selected : null,
      child: Material(
        color: background,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: dense ? 14 : 16, color: foreground),
                if (label != null) ...<Widget>[
                  SizedBox(width: gap),
                  Text(
                    label!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: foreground),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
