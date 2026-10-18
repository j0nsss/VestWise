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

  group('neutral text scale clears 4.5:1 on every surface (P8-T1)', () {
    for (final Brightness brightness in Brightness.values) {
      final String name = brightness.name;
      // Text can land on the page background, on a soft/grouped surface or on a
      // card, so all three must clear the threshold.
      final Map<String, Color> surfaces = <String, Color>{
        'surface': AppColors.surfaceFor(brightness),
        'surfaceSoft': AppColors.surfaceSoftFor(brightness),
        'surfaceContainerHighest':
            AppColors.surfaceContainerHighestFor(brightness),
      };
      final Map<String, Color> tones = <String, Color>{
        'textPrimary': AppColors.textPrimaryFor(brightness),
        'textSecondary': AppColors.textSecondaryFor(brightness),
        'textTertiary': AppColors.textTertiaryFor(brightness),
      };

      for (final MapEntry<String, Color> surface in surfaces.entries) {
        for (final MapEntry<String, Color> tone in tones.entries) {
          test('${tone.key} on $name ${surface.key}', () {
            expect(
              contrastRatio(tone.value, surface.value),
              greaterThanOrEqualTo(4.5),
            );
          });
        }
      }
    }
  });

  group('neutral surfaces are distinct tones (P8-T1)', () {
    for (final Brightness brightness in Brightness.values) {
      test('${brightness.name}: surface, surfaceSoft and card differ', () {
        final Set<Color> tones = <Color>{
          AppColors.surfaceFor(brightness),
          AppColors.surfaceSoftFor(brightness),
          AppColors.surfaceContainerHighestFor(brightness),
        };

        expect(tones, hasLength(3));
      });
    }

    test('the theme maps the warm neutrals onto the ColorScheme', () {
      for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        expect(theme.colorScheme.surface, AppColors.surfaceFor(theme.brightness));
        expect(
          theme.colorScheme.onSurface,
          AppColors.textPrimaryFor(theme.brightness),
        );
        expect(
          theme.colorScheme.onSurfaceVariant,
          AppColors.textSecondaryFor(theme.brightness),
        );
        expect(
          theme.colorScheme.surfaceContainerHighest,
          AppColors.surfaceContainerHighestFor(theme.brightness),
        );
      }
    });
  });

  group('tag palette pairs clear 4.5:1 (P8-T1)', () {
    for (final Brightness brightness in Brightness.values) {
      for (final AppTag tag in AppTag.values) {
        test('${brightness.name} ${tag.name}', () {
          final AppTagColor pair = AppColors.tagFor(tag, brightness);

          expect(
            contrastRatio(pair.foreground, pair.background),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }

    test('every tag is a distinct pair', () {
      for (final Brightness brightness in Brightness.values) {
        final List<AppTagColor> palette =
            AppColors.tagPaletteFor(brightness);

        expect(palette, hasLength(AppTag.values.length));
        expect(
          palette.map((AppTagColor p) => p.background).toSet(),
          hasLength(AppTag.values.length),
        );
      }
    });

    test('index lookup wraps around and stays stable', () {
      expect(
        AppColors.tagForIndex(0, Brightness.light).background,
        AppColors.tagFor(AppTag.red, Brightness.light).background,
      );
      expect(
        AppColors.tagForIndex(AppTag.values.length, Brightness.dark).background,
        AppColors.tagFor(AppTag.red, Brightness.dark).background,
      );
    });
  });

  group('borderSubtle is a visible hairline, not a WCAG boundary (P8-T1)', () {
    // Hairline borders are decorative, so WCAG 1.4.11's 3:1 non-text rule does
    // not apply. All we require is that the border is *perceptible* against the
    // surfaces it separates rather than invisible.
    for (final Brightness brightness in Brightness.values) {
      test('${brightness.name}: perceptible on the page and card surfaces', () {
        final Color border = AppColors.borderSubtleFor(brightness);

        expect(
          contrastRatio(border, AppColors.surfaceFor(brightness)),
          greaterThanOrEqualTo(1.1),
        );
        expect(
          contrastRatio(
            border,
            AppColors.surfaceContainerHighestFor(brightness),
          ),
          greaterThanOrEqualTo(1.1),
        );
      });
    }
  });
}
