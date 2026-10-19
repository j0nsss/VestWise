import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
/// The luminous-layer primitives from Phase 13 ("Obsidian Lumina").
///
/// Three pieces the mockups repeat everywhere:
///
/// * [VWGlowOrb] — a large, heavily blurred tinted ellipse that broadcasts a
///   soft ambient bloom across the canvas (primary violet top-left, mint
///   bottom-right, and so on). Purely decorative; must be excluded from
///   semantics and never intercepts pointers.
/// * [VWGlass] — a frosted panel: whatever is behind it gets an
///   [ImageFilter.blur], then a translucent surface tint, a hairline top
///   highlight and (optionally) a soft shadow. Used by the floating nav dock
///   and the screen headers.
/// * [vwGlowShadow] — the violet ambient bloom behind primary actions.
///
/// All of them read the theme, so they adapt to the retained light mode —
/// light mode keeps the blur but drops the tint alphas so the glass reads on
/// the pale canvas.
class VWGlowOrb extends StatelessWidget {
  const VWGlowOrb({
    required this.color,
    required this.size,
    this.alignment = Alignment.topLeft,
    this.opacity = 0.10,
    super.key,
  });

  final Color color;
  final double size;
  final AlignmentGeometry alignment;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Align(
          alignment: alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[color.withValues(alpha: opacity), color.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frost a region of the screen. Wrap a widget in [VWGlass] to get the
/// backdrop blur + translucent fill + hairline highlight of the mockups'
/// glassmorphism panels.
class VWGlass extends StatelessWidget {
  const VWGlass({
    required this.child,
    this.borderRadius = AppRadii.chip,
    this.tintAlpha = 0.85,
    this.shadow,

    super.key,
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final double tintAlpha;
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
                  alpha: brightness == Brightness.dark ? 0.35 : 0.08,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: AppColors.surfaceContainerFor(
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

/// The violet ambient bloom behind primary actions (`0 8px 24px -4px
/// rgba(99,102,241,0.35)` in the design; radius dialled per element).
List<BoxShadow> vwGlowShadow({double alpha = 0.35, double offsetY = 8}) =>
    <BoxShadow>[
      BoxShadow(
        color: AppColors.accentViolet.withValues(alpha: alpha),
        blurRadius: 24,
        offset: Offset(0, offsetY),
      ),
    ];

/// The luminous sheet gradient hero cards use (`surface-container-high →
/// container → lowest`, diagonal). Stands in for the mockups' card gradient
/// without a bespoke widget per feature.
BoxDecoration vwHeroCardDecoration(BuildContext context) {
  final Brightness brightness = Theme.of(context).brightness;
  return BoxDecoration(
    borderRadius: AppRadii.card,
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: <Color>[
        AppColors.surfaceHighFor(brightness),
        AppColors.surfaceContainerFor(brightness),
        AppColors.surfaceLowestFor(brightness),
      ],
    ),
  );
}

/// Clearance every scrollable needs at its bottom so content cannot hide
/// behind the floating dock (64 dock height + 16 bottom margin + 8 breathing).
const double vwDockClearance = 88;
