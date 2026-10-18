import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';

/// A minimal line chart for a short series, hand-painted (plan2.md P10-FIN-2).
///
/// Deliberately not a chart package: seven points neither need axes, labels nor
/// an interaction layer, and `fl_chart` already carries the bar and ring charts
/// elsewhere. The geometry lives in [normalizedPoints] so it can be tested
/// without a canvas.
class VWSparkline extends StatelessWidget {
  const VWSparkline({
    required this.values,
    this.color,
    this.height = 36,
    this.strokeWidth = 2,
    this.fill = true,
    super.key,
  });

  /// The series, oldest first. Empty means "no data yet".
  final List<double> values;

  /// Defaults to the income/expense tone for the *last* value, so a week that
  /// ends positive reads green and one that ends negative reads red.
  final Color? color;

  final double height;
  final double strokeWidth;
  final bool fill;

  /// Maps [values] onto 0..1 offsets, `y` increasing downwards as in a canvas.
  ///
  /// The scale is anchored at zero: a flat line means "no net change", not "a
  /// flat week of large numbers" — otherwise a week of +1000, +1000, +1000
  /// would look identical to a week of zeroes. When every value is zero the
  /// line sits on the baseline.
  static List<Offset> normalizedPoints(List<double> values) {
    if (values.isEmpty) {
      return const <Offset>[];
    }

    double magnitude = 0;
    for (final double value in values) {
      magnitude = math.max(magnitude, value.abs());
    }
    // Guard against a division by zero on an all-zero (or all-equal-to-zero)
    // week: fall back to a flat baseline rather than NaN offsets.
    final double scale = magnitude == 0 ? 1 : magnitude;

    return <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          values.length == 1 ? 0.5 : i / (values.length - 1),
          // 0.5 is the middle; positive values sit above it, negative below.
          0.5 - (values[i] / scale) * 0.5,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double last = values.isEmpty ? 0 : values.last;
    final Color stroke =
        color ??
        (last < 0
            ? AppColors.expenseFor(brightness)
            : AppColors.incomeFor(brightness));

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: stroke,
          strokeWidth: strokeWidth,
          fill: fill,
          // The line must not be cropped at the extremes, and the fill needs
          // somewhere to go.
          padding: strokeWidth / 2 + 1,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.fill,
    required this.padding,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool fill;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;
    final List<Offset> points = VWSparkline.normalizedPoints(values)
        .map(
          (Offset p) => Offset(
            padding + p.dx * math.max(0, size.width - padding * 2),
            padding + p.dy * math.max(0, size.height - padding * 2),
          ),
        )
        .toList(growable: false);

    // No data: a flat baseline reads as "nothing happened yet" and, unlike an
    // exception, is allowed on a fresh install.
    if (points.isEmpty) {
      canvas.drawLine(
        Offset(padding, midY),
        Offset(size.width - padding, midY),
        _strokePaint()..color = color.withValues(alpha: 0.35),
      );
      return;
    }

    final Path line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    if (fill && points.length > 1) {
      final Path area = Path.from(line)
        ..lineTo(points.last.dx, midY)
        ..lineTo(points.first.dx, midY)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }

    canvas.drawPath(line, _strokePaint());

    // A dot on the latest figure: the one number the card is really about.
    canvas.drawCircle(points.last, strokeWidth, Paint()..color = color);
  }

  Paint _strokePaint() => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.fill != fill ||
      oldDelegate.values.length != values.length ||
      !_sameValues(oldDelegate.values);

  bool _sameValues(List<double> other) {
    for (int i = 0; i < values.length; i++) {
      if (values[i] != other[i]) {
        return false;
      }
    }

    return true;
  }
}
