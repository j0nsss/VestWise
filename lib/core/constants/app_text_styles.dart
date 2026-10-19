import 'package:flutter/material.dart';

/// Typography roles — Phase 13 ("Obsidian Lumina"), built on the bundled
/// Plus Jakarta Sans family, replacing plan §1.5 / plan2.md P8-T3's Inter
/// scale. Type values track the design system's scale
/// (display-lg-mobile 36/800, headline 26/24/20, title 16, body 16/14/12,
/// labels 14/12/11 with wide tracking on the smallest tier).
///
/// The full Material 3 scale is defined on purpose (plan2.md P8-T3). The theme
/// installs this via `textTheme:`, which *replaces* rather than merges the
/// default scale — so any role left out here resolves to `null` and its text
/// silently falls back to whatever `DefaultTextStyle` happens to be. That had
/// already bitten many roles the app uses; `app_text_styles_test.dart` asserts
/// none of them is null.
///
/// Weights carry the hierarchy per the design: display is 800, headlines
/// 700–600, titles 600, body 400, labels 600–700. Letter-spacing follows the
/// design tokens (tight on display, wide on label-sm).
abstract final class AppTextStyles {
  static const String fontFamily = 'PlusJakartaSans';

  /// The legacy bundled family, still registered for detail screens.
  static const String legacyFontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -1.25,
    ),
    displayMedium: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -1.0,
    ),
    // display-lg-mobile (36/44, w800, -0.025em) — hero metrics.
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      height: 1.22,
      letterSpacing: -0.9,
    ),
    // headline-lg (32/40, w700, -0.02em).
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.64,
    ),
    // headline-md (24/32, w600, -0.015em).
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: -0.36,
    ),
    // headline-sm (20/28, w600, -0.01em).
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: -0.2,
    ),
    // headline-lg-mobile (26/34, w700, -0.02em) rides titleLarge's size slot.
    titleLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.31,
      letterSpacing: -0.52,
    ),
    // title-md (16/24, w600).
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.45,
    ),
    // body-lg (16/24, w400).
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    // body-md (14/20, w400, +0.005em).
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.07,
    ),
    // body-sm (12/16, w400, +0.01em).
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.12,
    ),
    // label-lg (14/20, w600, +0.01em).
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.14,
    ),
    // label-md (12/16, w600, +0.02em).
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0.24,
    ),
    // label-sm (11/14, w700, +0.06em) — micro-tags, uppercase by call site.
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.27,
      letterSpacing: 0.66,
    ),
  );
}
