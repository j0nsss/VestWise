import 'package:flutter/material.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';
import 'package:vestwise/core/constants/app_motion.dart';

/// The design's primary quick action: a 56px full circle in `primary-container`
/// (pistachio) lifting off a shadow tinted by its own fill. Every screen's
/// `FloatingActionButton` becomes one of these; the semantics and tap behaviour
/// stay Material's.
class VWFab extends StatefulWidget {
  const VWFab({required this.child, this.onPressed, this.tooltip, super.key});

  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  State<VWFab> createState() => _VWFabState();
}

class _VWFabState extends State<VWFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget fab = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: vwTactileShadow(
          theme.colorScheme.primaryContainer,
          theme.brightness,
        ),
      ),
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        shape: const CircleBorder(),
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: AnimatedScale(
          scale: _pressed ? AppMotion.pressedScale : 1,
          duration: motionDuration(context, AppMotion.stateChange),
          curve: AppMotion.standardCurve,
          child: widget.child,
        ),
      ),
    );

    final Widget result = widget.tooltip == null
        ? fab
        : Tooltip(message: widget.tooltip!, child: fab);

    // `Listener` rather than button callbacks: it sees the touch-down even
    // when the gesture turns into a scroll, same as VWButton (P11-T4).
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: result,
    );
  }
}

/// Puts the FAB at the far end, one comfortable gap above the floating dock
/// (`bottom-24 right-5` in the mockups = 96px from the bottom, 20px from the
/// right; Flutter's FAB insets are 16px anchored, so the bottom sits at 96).
class VWFabLocation extends FloatingActionButtonLocation {
  const VWFabLocation();

  /// 80px clears the floating dock (16 margin + 64 height), +16 gap = 96.
  static const double _bottomClearance = 96;
  static const double _endMargin = 16;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    return Offset(
      scaffoldGeometry.scaffoldSize.width -
          scaffoldGeometry.floatingActionButtonSize.width -
          _endMargin,
      scaffoldGeometry.contentBottom - fabHeight - _bottomClearance,
    );
  }

  @override
  String toString() => 'VWFabLocation(above dock, end)';
}

/// A static-centred sibling, unused today but kept symmetrical with
/// [VWFabLocation] in case a screen needs a centred action later.
class VWFabCenteredLocation extends FloatingActionButtonLocation {
  const VWFabCenteredLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    return Offset(
      (scaffoldGeometry.scaffoldSize.width -
              scaffoldGeometry.floatingActionButtonSize.width) /
          2,
      scaffoldGeometry.contentBottom - fabHeight - 96,
    );
  }
}
