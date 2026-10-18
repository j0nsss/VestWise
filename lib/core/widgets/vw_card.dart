import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_spacing.dart';

/// How a [VWCard] sits against the page (plan2.md P8-T4).
enum VWCardVariant {
  /// Page background surface, separated by a hairline border. The default, and
  /// the right choice for almost everything.
  flat,

  /// A *grouped* surface ([AppColors.surfaceSoft]), no border — used when a card
  /// is nested inside another one or when several cards sit together and
  /// borders would start to chatter.
  soft,

  /// Genuinely floating content. The only variant allowed a shadow, and it uses
  /// the same modest elevation as overlays.
  elevated,
}

/// Base container for card-based layouts (plan P1-T6, extended in plan2.md
/// P8-T4). Styling (radius, background, border) comes from the theme or from
/// [variant], so features never define their own.
///
/// When [onTap] is set the card presses in slightly on touch-down — the shared
/// [AppMotion.pressedScale] over [AppMotion.stateChange], skipped entirely when
/// the platform asks for reduced motion. Pressing a card and pressing a
/// `VWButton` answer with the same gesture on purpose (P11-T4).
class VWCard extends StatefulWidget {
  const VWCard({
    required this.child,
    this.onTap,
    this.variant = VWCardVariant.flat,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VWCardVariant variant;
  final EdgeInsetsGeometry padding;

  @override
  State<VWCard> createState() => _VWCardState();
}

class _VWCardState extends State<VWCard> {
  bool _pressed = false;

  void _setPressed({required bool pressed}) {
    if (_pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final bool interactive = widget.onTap != null;
    final (
      Color? color,
      ShapeBorder? shape,
      double? elevation,
    ) = switch (widget.variant) {
      // Inherit the theme's card decoration untouched.
      VWCardVariant.flat => (null, null, null),
      VWCardVariant.soft => (
        AppColors.surfaceSoft(context),
        const RoundedRectangleBorder(borderRadius: AppRadii.card),
        AppElevation.flat,
      ),
      VWCardVariant.elevated => (
        null,
        const RoundedRectangleBorder(borderRadius: AppRadii.card),
        AppElevation.overlay,
      ),
    };

    final Widget content = Padding(
      padding: widget.padding,
      child: widget.child,
    );

    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      color: color,
      shape: shape,
      elevation: elevation,
      child: interactive
          ? InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _setPressed(pressed: true),
              onTapUp: (_) => _setPressed(pressed: false),
              onTapCancel: () => _setPressed(pressed: false),
              borderRadius: AppRadii.card,
              child: content,
            )
          : content,
    );

    if (interactive) {
      card = AnimatedScale(
        scale: _pressed ? AppMotion.pressedScale : 1,
        duration: motionDuration(context, AppMotion.stateChange),
        curve: AppMotion.standardCurve,
        child: card,
      );
    }

    return card;
  }
}
