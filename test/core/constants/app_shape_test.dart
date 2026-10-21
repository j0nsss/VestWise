import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/theme/app_theme.dart';

/// Shape and elevation tokens (plan2.md P8-T2).
void main() {
  group('AppRadii', () {
    test('card and input keep their existing values', () {
      expect(AppRadii.cardValue, 16);
      expect(AppRadii.inputValue, 12);
      expect(
        AppRadii.card,
        const BorderRadius.all(Radius.circular(AppRadii.cardValue)),
      );
    });

    test(
      'sheet rounds only the top, so it sits flush with the bottom edge',
      () {
        expect(AppRadii.sheetValue, 24);
        expect(AppRadii.sheet.topLeft.x, AppRadii.sheetValue);
        expect(AppRadii.sheet.topRight.x, AppRadii.sheetValue);
        expect(AppRadii.sheet.bottomLeft, Radius.zero);
        expect(AppRadii.sheet.bottomRight, Radius.zero);
      },
    );

    test('chip is a pill', () {
      expect(AppRadii.chip.topLeft.x, greaterThanOrEqualTo(100));
    });
  });

  group('AppElevation', () {
    test('cards are flat and only overlays float', () {
      expect(AppElevation.flat, 0);
      expect(AppElevation.overlay, greaterThan(0));
    });

    test('the only shadow blur in the app stays at or under 8dp', () {
      // plan2.md §10: "No shadow with blur > 8dp anywhere outside a true
      // overlay (dialog/bottom sheet)." Phase 14 (Omotive) reopened this: the
      // coloured tactile cards and the floating dock are deliberate lifts, so
      // the ceiling now applies to overlays and the neutral layers only.
      expect(AppElevation.overlayBlur, lessThanOrEqualTo(8));
      expect(AppElevation.flat, 0);
    });

    test('the Omotive lifts are named and ordered', () {
      // Tactile cards lift softly with a fill-tinted shadow; the dock, which
      // genuinely hovers over scrolling content, is the deepest layer.
      expect(AppElevation.tactile, greaterThan(AppElevation.flat));
      expect(AppElevation.tactileBlur, greaterThan(AppElevation.overlayBlur));
      expect(AppElevation.dock, greaterThan(AppElevation.tactile));
      expect(AppElevation.dockBlur, greaterThan(AppElevation.tactileBlur));
    });
  });

  group('the theme wires the shape tokens in (P8-T2)', () {
    for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      test(
        '${theme.brightness.name}: cards are flat and borderless',
        () {
          expect(theme.cardTheme.elevation, AppElevation.flat);
          expect(theme.appBarTheme.elevation, AppElevation.flat);
          expect(theme.appBarTheme.scrolledUnderElevation, AppElevation.flat);

          // Phase 14: the default card is the neutral list-row surface —
          // filled `surfaceContainerHigh` at the row radius, so a bare `VWCard`
          // matches a list row. Coloured tactile cards opt into 28 themselves.
          final ShapeBorder? shape = theme.cardTheme.shape;
          expect(shape, isA<RoundedRectangleBorder>());
          expect(
            (shape! as RoundedRectangleBorder).borderRadius,
            AppRadii.row,
          );
          expect((shape as RoundedRectangleBorder).side.width, 0);
          expect(theme.cardTheme.color, theme.colorScheme.surfaceContainerHigh);
        },
      );

      test('${theme.brightness.name}: overlays are the elevated exception', () {
        expect(theme.bottomSheetTheme.shape, isNotNull);
        expect(theme.bottomSheetTheme.elevation, AppElevation.overlay);
        expect(theme.dialogTheme.elevation, AppElevation.overlay);
      });
    }
  });
}
