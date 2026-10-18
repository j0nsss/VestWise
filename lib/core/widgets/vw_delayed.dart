import 'dart:async';

import 'package:flutter/material.dart';

/// Shows [child] only once [delay] has passed (plan2.md P11-T2).
///
/// The anti-flicker gate for skeletons. Local Isar normally answers in well
/// under 100ms, so a skeleton built immediately would flash on nearly every
/// open; held back by this gate, a fast read never shows one at all and a slow
/// one shows a skeleton that stays until the data arrives. Because the gate
/// lives here, no screen re-implements the timing.
///
/// The timer is cancelled with the widget, so "loading finished" is simply this
/// widget going away — there is no state to reset and no callback to remember.
class VWDelayed extends StatefulWidget {
  const VWDelayed({required this.child, this.delay = defaultDelay, super.key});

  /// Roughly one frame budget plus a comfortable margin: below this a
  /// placeholder reads as a flicker rather than as feedback.
  static const Duration defaultDelay = Duration(milliseconds: 100);

  final Widget child;
  final Duration delay;

  @override
  State<VWDelayed> createState() => _VWDelayedState();
}

class _VWDelayedState extends State<VWDelayed> {
  Timer? _timer;
  bool _elapsed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant VWDelayed oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new child while we are still waiting means a new wait; a new child
    // after the gate opened needs no timer at all.
    if (oldWidget.child != widget.child && !_elapsed) {
      _timer?.cancel();
      _start();
    }
  }

  void _start() {
    if (widget.delay == Duration.zero) {
      _elapsed = true;

      return;
    }
    _timer = Timer(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() => _elapsed = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _elapsed ? widget.child : const SizedBox.shrink();
}
