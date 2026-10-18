import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/theme/app_theme.dart';

/// WCAG 2.1 relative luminance of a single colour channel.
double _linearize(double channel) => channel <= 0.03928
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color color) =>
    0.2126 * _linearize(color.r) +
    0.7152 * _linearize(color.g) +
    0.0722 * _linearize(color.b);

/// WCAG 2.1 contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double lighter = math.max(la, lb);
  final double darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('money figures clear the 4.5:1 text threshold (P5-T3)', () {
    for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      final String name = theme.brightness.name;
      // Money is painted both on the plain scaffold surface (list rows) and on
      // the raised card surface (summary cards), so both must pass.
      final Map<String, Color> surfaces = <String, Color>{
        'surface': theme.colorScheme.surface,
        'surfaceContainerHighest': theme.colorScheme.surfaceContainerHighest,
      };

      for (final MapEntry<String, Color> surface in surfaces.entries) {
        test('income on $name ${surface.key}', () {
          expect(
            contrastRatio(AppColors.incomeFor(theme.brightness), surface.value),
            greaterThanOrEqualTo(4.5),
          );
        });

        test('expense on $name ${surface.key}', () {
          expect(
            contrastRatio(AppColors.expenseFor(theme.brightness), surface.value),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }
  });
}
