import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_text_styles.dart';

/// The tactile-card primitives of Phase 14 ("Omotive Style").
///
/// The Omotive screens repeat one idea everywhere: a **coloured, lifted,
/// fully-rounded card** whose fill is the accent, carrying a small uppercase
/// kicker, a bold title, a translucent round action, a meta row and an inset
/// "shelf" capsule at the bottom. Depth comes from a shadow tinted by the
/// card's own fill, never from a border.
///
/// Everything here reads the theme, so the retained light mode keeps working:
/// light mode uses the same tones, one step deeper where text ink is painted.

/// Which colour block a tactile card is.
///
/// The names are the design's roles, not its hues: a "momentum" card is amber
/// in the mockups *and* in light mode. Glow is deliberately absent — the
/// Omotive language has no glow orbs.
enum VWTactileTone {
  /// Balance, hero metrics, income — the design's `primary-container`.
  pistachio,

  /// Momentum, budget, "today" — the design's `secondary`.
  amber,

  /// Urgent, largest expense, high priority — `tertiary-container`.
  coral,

  /// Completed / passive blocks — `surface-container-high`.
  charcoal,
}

/// Fill and ink for a tone, per brightness.
class VWTactilePalette {
  const VWTactilePalette({
    required this.fill,
    required this.ink,
    required this.softInk,
    required this.actionInk,
  });

  /// The card's surface colour.
  final Color fill;

  /// Full-strength ink for titles on [fill].
  final Color ink;

  /// Dimmed ink for kickers, meta rows and secondary lines on [fill].
  final Color softInk;

  /// Ink for the translucent round action on [fill].
  final Color actionInk;

  VWTactilePalette copyWith({Color? actionInk}) => VWTactilePalette(
    fill: fill,
    ink: ink,
    softInk: softInk,
    actionInk: actionInk ?? this.actionInk,
  );
}

VWTactilePalette _paletteFor(VWTactileTone tone, Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  switch (tone) {
    case VWTactileTone.pistachio:
      return VWTactilePalette(
        fill: AppColors.pistachio,
        ink: AppColors.pistachioDeep,
        softInk: AppColors.pistachioDeep.withValues(alpha: 0.8),
        actionInk: AppColors.pistachioDeep,
      );
    case VWTactileTone.amber:
      return VWTactilePalette(
        fill: AppColors.amber,
        ink: AppColors.amberDeep,
        softInk: AppColors.amberDeep.withValues(alpha: 0.75),
        actionInk: AppColors.amberDeep,
      );
    case VWTactileTone.coral:
      return VWTactilePalette(
        fill: AppColors.coral,
        ink: AppColors.coralDeep,
        softInk: AppColors.coralDeep.withValues(alpha: 0.8),
        actionInk: AppColors.coralDeep,
      );
    case VWTactileTone.charcoal:
      return VWTactilePalette(
        fill: isDark ? AppColors.charcoal : AppColors.surfaceContainerLight,
        ink: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        softInk: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        actionInk: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      );
  }
}

/// The lift under a tactile card: a shadow in the card's own colour, so a
/// pistachio block casts a pistachio shadow rather than a generic grey one.
List<BoxShadow> vwTactileShadow(
  Color fill,
  Brightness brightness,
) => <BoxShadow>[
  BoxShadow(
    color: fill.withValues(alpha: brightness == Brightness.dark ? 0.22 : 0.30),
    blurRadius: AppElevation.tactileBlur,
    offset: const Offset(0, AppElevation.tactile),
  ),
];

/// A coloured tactile card — the Omotive language's core surface.
class VWTactileCard extends StatelessWidget {
  const VWTactileCard({
    required this.child,
    this.tone = VWTactileTone.charcoal,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.lifted = true,
    super.key,
  });

  final Widget child;
  final VWTactileTone tone;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  /// Neutral (charcoal) cards sit flat like every other panel; the coloured
  /// ones are lifted, which is what makes a filled card read as a card.
  final bool lifted;

  /// Fill and ink for [tone] at the current brightness.
  static VWTactilePalette paletteOf(BuildContext context, VWTactileTone tone) =>
      _paletteFor(tone, Theme.of(context).brightness);

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final VWTactilePalette palette = _paletteFor(tone, brightness);
    final bool isLifted = lifted && tone != VWTactileTone.charcoal;

    final Widget body = Material(
      color: palette.fill,
      borderRadius: AppRadii.tactile,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.tactile,
        child: Padding(padding: padding, child: child),
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: AppRadii.tactile,
        boxShadow: isLifted ? vwTactileShadow(palette.fill, brightness) : null,
      ),
      child: body,
    );
  }
}

/// The small uppercase kicker at the top of a tactile card, with the design's
/// leading status dot.
class VWTactileKicker extends StatelessWidget {
  const VWTactileKicker({
    required this.label,
    required this.ink,
    this.dotColor,
    this.trailing,
    super.key,
  });

  final String label;
  final Color ink;

  /// When non-null a 6px dot is painted before the label (the mockups use it
  /// on the primary/critical cards only).
  final Color? dotColor;

  /// Right-aligned slot, e.g. a pill.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = AppTextStyles.textTheme.labelSmall!.copyWith(
      color: ink,
      letterSpacing: 0.5,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (dotColor != null) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

/// The translucent round action inside a tactile card (share, tune, notify…).
/// 44px, per the design's `w-11 h-11`.
class VWCardAction extends StatelessWidget {
  const VWCardAction({
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.ink,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final Color resolved = ink ?? Theme.of(context).colorScheme.onSurface;
    final Widget button = Material(
      color: Colors.black.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: resolved),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(message: tooltip!, child: button),
    );
  }
}

/// The inset "shelf" capsule a tactile card ends with: a translucent
/// sub-surface holding a facepile / meta line on the left and a status pill on
/// the right.
class VWCardShelf extends StatelessWidget {
  const VWCardShelf({
    required this.leading,
    this.trailing,
    this.inset = 1.5,
    super.key,
  });

  final Widget leading;
  final Widget? trailing;

  /// How much of the card's own ink to mix into the shelf fill (the design
  /// uses `surface-container-lowest/15`).
  final double inset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.08 * inset),
        borderRadius: AppRadii.chip,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: leading),
          ?trailing,
        ],
      ),
    );
  }
}

/// A capsule label — the design's pills for priority, status and metadata.
class VWPill extends StatelessWidget {
  const VWPill({
    required this.label,
    this.background,
    this.foreground,
    this.icon,
    this.onTap,
    this.uppercase = true,
    this.dense = true,
    super.key,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool uppercase;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bg = background ?? theme.colorScheme.surfaceContainerHighest;
    final Color fg = foreground ?? theme.colorScheme.onSurface;

    final Widget content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.md : AppSpacing.lg,
        vertical: dense ? 6 : AppSpacing.sm,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            uppercase ? label.toUpperCase() : label,
            style: AppTextStyles.textTheme.labelSmall!.copyWith(
              color: fg,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, borderRadius: AppRadii.chip, child: content);
  }
}

/// One capsule in a date/period strip. The active capsule is painted in the
/// design's amber accent with dark ink and a pulse dot.
class VWDateCapsule extends StatelessWidget {
  const VWDateCapsule({
    required this.primary,
    this.secondary,
    this.active = false,
    this.onTap,
    this.compact = false,
    super.key,
  });

  /// The bold line — a day number, or the active label ("08 Apr").
  final String primary;

  /// The quiet line above — a weekday ("Mon", "Today").
  final String? secondary;

  final bool active;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color fill = active ? scheme.secondary : scheme.surfaceContainerHigh;
    final Color ink = active ? scheme.onSecondary : scheme.onSurfaceVariant;

    return Semantics(
      button: onTap != null,
      selected: active,
      label: secondary == null ? primary : '$secondary $primary',
      child: Material(
        color: fill,
        borderRadius: AppRadii.chip,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.chip,
          child: Container(
            constraints: BoxConstraints(minWidth: compact ? 56 : 64),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (secondary != null)
                  Text(
                    secondary!.toUpperCase(),
                    style: AppTextStyles.textTheme.labelSmall!.copyWith(
                      color: ink.withValues(alpha: 0.75),
                      letterSpacing: 0.4,
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (active) ...<Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: AppSpacing.xs),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ink,
                        ),
                      ),
                    ],
                    Text(
                      primary,
                      style: AppTextStyles.textTheme.labelLarge!.copyWith(
                        color: ink,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrolling strip of [VWDateCapsule]s (or any capsule).
class VWCapsuleStrip extends StatelessWidget {
  const VWCapsuleStrip({required this.children, this.padding, super.key});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) =>
            Center(child: children[index]),
      ),
    );
  }
}

/// The 2-column "bento" stat tile: a quiet uppercase label with a glyph, a
/// bold figure and a delta line.
class VWBentoTile extends StatelessWidget {
  const VWBentoTile({
    required this.label,
    required this.value,
    this.caption,
    this.captionColor,
    this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final Color? captionColor;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: AppRadii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: AppTextStyles.textTheme.labelSmall!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null)
                    Icon(
                      icon,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: theme.textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: AppTextStyles.textTheme.bodySmall!.copyWith(
                    color: captionColor ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A circular tinted glyph slot — the leading element of list rows
/// (transactions, events, notes).
class VWIconTile extends StatelessWidget {
  const VWIconTile({
    required this.icon,
    this.color,
    this.background,
    this.size = 48,
    super.key,
  });

  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fg = color ?? scheme.onSurface;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background ?? fg.withValues(alpha: 0.16),
      ),
      child: Icon(icon, size: size * 0.42, color: fg),
    );
  }
}

/// Frost a region of the screen — the dock and overlay headers.
///
/// Omotive is much drier with glass than Obsidian Lumina was: the dock is the
/// only large frosted surface, so the defaults here lean dark and opaque.
class VWGlass extends StatelessWidget {
  const VWGlass({
    required this.child,
    this.borderRadius = AppRadii.chip,
    this.tintAlpha = 0.92,
    this.blur = 24,
    this.shadow,
    super.key,
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final double tintAlpha;
  final double blur;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow:
            shadow ??
            <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: brightness == Brightness.dark ? 0.45 : 0.12,
                ),
                blurRadius: AppElevation.dockBlur,
                offset: const Offset(0, AppElevation.dock),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: AppColors.surfaceHighFor(
                brightness,
              ).withValues(alpha: tintAlpha),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: brightness == Brightness.dark ? 0.10 : 0.45,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Per-tone palette access from a `BuildContext`, for call sites that need the
/// ink without building a card.
VWTactilePalette vwTactilePalette(BuildContext context, VWTactileTone tone) =>
    VWTactileCard.paletteOf(context, tone);

/// Clearance every scrollable needs at its bottom so content cannot hide
/// behind the floating dock (64 dock height + 16 bottom margin + 8 breathing).
const double vwDockClearance = 88;

/// The 20px page margin the Omotive screens use (`px-margin`).
const double vwPageMargin = 20;

/// The design's pill height — every capsule and header action paints 40px of
/// content, wrapped in a 48px tap target.
const double vwPillHeight = 40;

/// The header's height (`h-20` in the mockups).
const double vwHeaderHeight = 80;
