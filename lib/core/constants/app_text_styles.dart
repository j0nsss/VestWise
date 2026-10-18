import 'package:flutter/material.dart';

/// Typography roles from plan §1.5, built on the bundled Inter family.
///
/// The full Material 3 scale is defined on purpose (plan2.md P8-T3). The theme
/// installs this via `textTheme:`, which *replaces* rather than merges the
/// default scale — so any role left out here resolves to `null` and its text
/// silently falls back to whatever `DefaultTextStyle` happens to be. That had
/// already bitten `titleSmall`, `bodySmall`, `headlineMedium`, `labelMedium`,
/// `labelLarge`, `headlineSmall` and `bodyLarge`, all of which the app uses.
/// `app_text_styles_test.dart` asserts none of them is null.
///
/// Weights carry the hierarchy: display/headline/title are 600–700, body is
/// 400, labels are 500. Line-heights are tightened slightly from Material's
/// defaults so dense lists (transactions, tasks) read as one block.
abstract final class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 1.18,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: -0.2,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.25,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.25,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.25,
      letterSpacing: 0.1,
    ),
  );
}
