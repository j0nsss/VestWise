import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/widgets/vw_inline_spinner.dart';

enum VWButtonVariant { primary, secondary, destructive }

/// Consistent action button with primary/secondary/destructive variants
/// (plan P1-T6).
///
/// While it can be pressed the button presses in slightly on touch-down — the
/// shared [AppMotion.pressedScale] over [AppMotion.stateChange], the same
/// gesture a card makes (P11-T4), and skipped entirely under reduced motion.
/// A disabled or loading button does not react, because it does not respond.
class VWButton extends StatefulWidget {
  const VWButton({
    required this.label,
    this.onPressed,
    this.variant = VWButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final VWButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  State<VWButton> createState() => _VWButtonState();
}

class _VWButtonState extends State<VWButton> {
  bool _pressed = false;

  void _setPressed({required bool pressed}) {
    if (_pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final VoidCallback? effectiveOnPressed =
        widget.isLoading ? null : widget.onPressed;

    final Widget child = widget.isLoading
        ? const VWInlineSpinner()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(widget.label),
            ],
          );

    final Widget button = switch (widget.variant) {
      VWButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      VWButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      VWButtonVariant.destructive => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
        ),
        child: child,
      ),
    };

    final Widget sized = widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;

    if (effectiveOnPressed == null) {
      return sized;
    }

    // A `Listener` rather than the button's own state callbacks: it needs no
    // change to the Material button, and it sees the touch-down that starts a
    // press even when the gesture later turns into a scroll.
    return AnimatedScale(
      scale: _pressed ? AppMotion.pressedScale : 1,
      duration: motionDuration(context, AppMotion.stateChange),
      curve: AppMotion.standardCurve,
      child: Listener(
        onPointerDown: (_) => _setPressed(pressed: true),
        onPointerUp: (_) => _setPressed(pressed: false),
        onPointerCancel: (_) => _setPressed(pressed: false),
        child: sized,
      ),
    );
  }
}
