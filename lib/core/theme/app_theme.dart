import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_text_styles.dart';

/// Builds the light and dark [ThemeData] from a single brand seed, per §1.5.
///
/// Elevation policy: flat surfaces with a warm neutral background and a thin
/// border rather than heavy shadows.
///
/// Surface policy (plan2.md P8-T1): the seed still decides the brand accent, but
/// every *neutral* role is overridden with [AppColors]' warm scale, so the app
/// is warm off-white / warm near-black instead of Material's cool indigo-tinted
/// surfaces. Widgets keep reading `Theme.of(context)` — nothing has to know.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
      // Overriding the neutral roles on top of the seeded scheme keeps the
      // brand hue (primary) intact while warming every surface and text tone.
    ).copyWith(
      surface: AppColors.surfaceFor(brightness),
      surfaceContainerHighest:
          AppColors.surfaceContainerHighestFor(brightness),
      onSurface: AppColors.textPrimaryFor(brightness),
      onSurfaceVariant: AppColors.textSecondaryFor(brightness),
      outlineVariant: AppColors.borderSubtleFor(brightness),
      // No elevation tint: surfaces are already the warm tones we want, so the
      // scheme must not re-tint them back towards the seed.
      surfaceTint: Colors.transparent,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // 48px is the minimum comfortable tap target (P5-T3).
          minimumSize: const Size(0, 48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: AppRadii.input),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadii.input),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadii.input),
        errorBorder: OutlineInputBorder(borderRadius: AppRadii.input),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppRadii.input),
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
