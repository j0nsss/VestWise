import 'package:flutter/material.dart';

/// Typography roles — Phase 14 ("Omotive Style") on the bundled Plus Jakarta
/// Sans family, replacing Phase 13's Obsidian Lumina scale.
///
/// The Omotive scale is short and punchy: a 36/44 extra-bold headline-xl for
/// hero metrics, 26/32 and 20/26 headlines for card titles, 16/22 title-sm for
/// rows, a 500-weight body (the design's body reads a step heavier than
/// Material's default 400), and 13/11 label tiers for the uppercase micro-tags.
///
/// The full Material 3 scale is defined on purpose (plan2.md P8-T3). The theme
/// installs this via `textTheme:`, which *replaces* rather than merges the
/// default scale — so any role left out here resolves to `null` and its text
/// silently falls back to whatever `DefaultTextStyle` happens to be.
/// `app_text_styles_test.dart` asserts none of them is null.
abstract final class AppTextStyles {
  static const String fontFamily = 'PlusJakartaSans';

  /// The legacy bundled family, still registered for detail screens.
  static const String legacyFontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -1.4,
    ),
    displayMedium: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -1.2,
    ),
    // headline-xl (36/44, w800, -0.03em) — hero metrics, balance readouts.
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      height: 1.22,
      letterSpacing: -1.08,
    ),
    // headline-lg (26/32, w700, -0.02em) — the header's screen title.
    headlineLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.23,
      letterSpacing: -0.52,
    ),
    // headline-md (20/26, w700, -0.015em) — tactile card titles.
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.3,
    ),
    // Gap-fill for the roles the Omotive scale does not name (onboarding,
    // dialogs); sits exactly between headline-md and title-sm.
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.33,
      letterSpacing: -0.2,
    ),
    // headline-lg again, for the places that reach for titleLarge by role.
    titleLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.23,
      letterSpacing: -0.52,
    ),
    // title-sm (16/22, w600).
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.38,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    // body-md (14/20, w500).
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.07,
    ),
    // body-sm (12/16, w500).
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.12,
    ),
    // label-lg — the design's pill/button ink (14/20, w700).
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.43,
      letterSpacing: 0.14,
    ),
    // label-md (13/16, w700, +0.01em) — capsule and chip labels.
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.23,
      letterSpacing: 0.13,
    ),
    // label-sm (11/14, w700, +0.02em) — micro-tags, uppercase by call site.
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.27,
      letterSpacing: 0.22,
    ),
  );
}
