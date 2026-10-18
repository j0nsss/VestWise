import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_motion.dart';

/// One placeholder bar in a loading skeleton (plan2.md P11-T1).
///
/// A static tinted block on its own; put it inside a [VWShimmer] to make a
/// whole row sweep together. Sizing is explicit — give the bar the height and
/// width of the text it stands in for, so the real content lands in exactly the
/// same place and nothing shifts when the data arrives.
class VWSkeleton extends StatelessWidget {
  const VWSkeleton({
    this.width,
    this.height,
    this.radius = _defaultRadius,
    super.key,
  });

  /// Height of a single line of body text, the most common bar.
  const VWSkeleton.line({this.width, super.key})
    : height = _lineHeight,
      radius = _defaultRadius;

  static const double _lineHeight = 12;
  static const double _defaultRadius = 6;

  /// Null means "as wide as the parent allows", which is what a full-width
  /// text line wants.
  final double? width;

  /// Null fills whatever height the parent hands down — used by bars that have
  /// to match a whole row (the calendar's accent bar).
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // `surfaceContainerHighest` is the theme's own slightly-raised tone, so
        // a skeleton looks like the app thinking rather than like a widget from
        // another app.
        color: AppColors.surfaceContainerHighestFor(
          Theme.of(context).brightness,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Sweeps a soft highlight across its children (plan2.md P11-T1).
///
/// One controller for the whole subtree rather than one per bar: a screen
/// showing six skeletons is six rectangles, not eighteen animations, and the
/// highlight travels across the row the way it does in a real skeleton.
///
/// Under reduced motion there is no sweep at all — the bars stay a plain static
/// tint, which is still a perfectly good "loading" signal without any motion.
///
/// This checks [prefersReducedMotion] rather than going through
/// [motionDuration] like every other animation does, and deliberately: a
/// zero-length `repeat()` is not "no animation", it is a busy loop. Skipping
/// the loop outright is the only correct answer here, so the single
/// decision-point rule does not reach this one case.
class VWShimmer extends StatefulWidget {
  const VWShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<VWShimmer> createState() => _VWShimmerState();
}

class _VWShimmerState extends State<VWShimmer>
    with SingleTickerProviderStateMixin {
  /// How much of the gradient one band takes up. Wider band = softer sweep.
  static const double _bandWidth = 0.35;

  /// How far the band travels: fully off one edge to fully off the other, so it
  /// enters and leaves instead of popping at the boundary.
  static const double _travel = 1 + 2 * _bandWidth;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.skeletonSweep,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (prefersReducedMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      // Restartable: coming back from a reduced-motion system setting should
      // not leave a screen frozen mid-load.
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return widget.child;
    }

    final Color highlight = AppColors.surfaceFor(Theme.of(context).brightness);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (Rect bounds) {
          final double start = -_bandWidth + _travel * _controller.value;
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              Colors.transparent,
              highlight.withValues(alpha: 0.75),
              Colors.transparent,
            ],
            stops: <double>[start, start + _bandWidth / 2, start + _bandWidth],
          ).createShader(bounds);
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// A list of identical skeleton rows, for a screen that is waiting on a list
/// (plan2.md P11-T2).
///
/// Takes the row rather than a builder because skeletons are stateless: the
/// same `const TaskRowSkeleton()` in every slot is the point, and the list is
/// never scrolled (the real data replaces it, usually within a frame or two).
class VWSkeletonList extends StatelessWidget {
  const VWSkeletonList({
    required this.row,
    this.count = 5,
    this.padding = EdgeInsets.zero,
    this.gap = 0,
    super.key,
  });

  final Widget row;
  final int count;
  final EdgeInsetsGeometry padding;

  /// Space between rows, for lists whose real rows are separated cards.
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (gap > 0) {
      return ListView.separated(
        padding: padding,
        itemCount: count,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: gap),
        itemBuilder: (BuildContext context, int index) => row,
      );
    }

    return ListView.builder(
      padding: padding,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => row,
    );
  }
}
