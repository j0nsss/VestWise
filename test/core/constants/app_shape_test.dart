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

    test('sheet rounds only the top, so it sits flush with the bottom edge', () {
      expect(AppRadii.sheetValue, 20);
      expect(AppRadii.sheet.topLeft.x, AppRadii.sheetValue);
      expect(AppRadii.sheet.topRight.x, AppRadii.sheetValue);
      expect(AppRadii.sheet.bottomLeft, Radius.zero);
      expect(AppRadii.sheet.bottomRight, Radius.zero);
    });

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
      // overlay (dialog/bottom sheet)."
      expect(AppElevation.overlayBlur, lessThanOrEqualTo(8));
    });
  });

  group('the theme wires the shape tokens in (P8-T2)', () {
    for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      test('${theme.brightness.name}: cards are flat with a hairline border',
          () {
        expect(theme.cardTheme.elevation, AppElevation.flat);
        expect(theme.appBarTheme.elevation, AppElevation.flat);
        expect(theme.appBarTheme.scrolledUnderElevation, AppElevation.flat);

        final ShapeBorder? shape = theme.cardTheme.shape;
        expect(shape, isA<RoundedRectangleBorder>());
        expect(
          (shape! as RoundedRectangleBorder).borderRadius,
          AppRadii.card,
        );
        expect((shape as RoundedRectangleBorder).side.width, 1);
      });

      test('${theme.brightness.name}: overlays are the elevated exception', () {
        expect(theme.bottomSheetTheme.shape, isNotNull);
        expect(theme.bottomSheetTheme.elevation, AppElevation.overlay);
        expect(theme.dialogTheme.elevation, AppElevation.overlay);
      });
    }
  });
}
