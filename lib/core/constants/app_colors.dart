import 'package:flutter/material.dart';

/// Brand + semantic colors from plan §1.5.
///
/// Only [seed] feeds the Material 3 [ColorScheme]; the semantic accents are
/// intentionally outside the seeded scheme so they stay stable across themes.
abstract final class AppColors {
  /// Brand seed used for both light and dark schemes.
  static const Color seed = Color(0xFF4F46E5);

  static const Color incomeGreen = Color(0xFF16A34A);
  static const Color expenseRed = Color(0xFFDC2626);

  static const Color priorityHigh = Color(0xFFDC2626);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF3B82F6);
}
