import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG 2.1 relative luminance of a single colour channel.
double _linearize(double channel) => channel <= 0.03928
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color color) =>
    0.2126 * _linearize(color.r) +
    0.7152 * _linearize(color.g) +
    0.0722 * _linearize(color.b);

/// WCAG 2.1 contrast ratio between two opaque colours.
///
/// Shared by the token tests and the widget tests that render a token (the
/// category chip, for one), so "4.5:1" is measured the same way everywhere.
double contrastRatio(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double lighter = math.max(la, lb);
  final double darker = math.min(la, lb);

  return (lighter + 0.05) / (darker + 0.05);
}
