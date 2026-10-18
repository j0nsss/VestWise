import 'package:flutter/material.dart';

/// Brand + semantic colors from plan §1.5.
///
/// Only [seed] feeds the Material 3 [ColorScheme]; the semantic accents are
/// intentionally outside the seeded scheme so they stay stable across themes.
///
/// Two tiers, because "a brand accent" and "readable money" are different
/// constraints (P5-T3):
/// * [incomeGreen] / [expenseRed] are the brand accents — they seed default
///   category colours and are *never* painted as on-surface text or as an
///   essential chart mark, because they do not clear WCAG contrast.
/// * [incomeFor] / [expenseFor] return a brightness-appropriate tone that
///   clears 4.5:1, and every money figure, sign and bar uses those.
///   `test/core/constants/app_colors_test.dart` asserts the ratios.
abstract final class AppColors {
  /// Brand seed used for both light and dark schemes.
  static const Color seed = Color(0xFF4F46E5);

  static const Color incomeGreen = Color(0xFF16A34A);
  static const Color expenseRed = Color(0xFFDC2626);

  static const Color priorityHigh = Color(0xFFDC2626);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF3B82F6);

  /// Green-700 — 5.0:1 on the light `surfaceContainerHighest`.
  static const Color incomeGreenLight = Color(0xFF166534);

  /// Red-800 — 5.5:1 on the light `surfaceContainerHighest`.
  static const Color expenseRedLight = Color(0xFFB91C1C);

  /// Green-400 — 7.0:1 on the dark `surfaceContainerHighest`.
  static const Color incomeGreenDark = Color(0xFF4ADE80);

  /// Red-300 — 6.5:1 on the dark `surfaceContainerHighest`.
  static const Color expenseRedDark = Color(0xFFFCA5A5);

  /// Income colour safe for text on the current surface.
  static Color incomeFor(Brightness brightness) =>
      brightness == Brightness.dark ? incomeGreenDark : incomeGreenLight;

  /// Expense colour safe for text on the current surface.
  static Color expenseFor(Brightness brightness) =>
      brightness == Brightness.dark ? expenseRedDark : expenseRedLight;
}
