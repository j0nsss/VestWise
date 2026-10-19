import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_text_styles.dart';

/// Builds the light and dark [ThemeData] — Phase 13 ("Obsidian Lumina", the
/// Stitch design system), replacing plan2.md P8-T1's warm-neutral mapping.
///
/// Dark is dark-first and *exact*: the scheme roles are the generated tokens
/// from the Stitch design system (obsidian canvases, electric violet
/// interactive driver, mint/coral status hues). Light is the violet-tinted
/// light adaptation of the same seed, so the ThemeMode toggle in Settings
/// stays functional.
///
/// Elevation policy (revises plan2.md P8-T2): depth comes from surface
/// luminance tiers and soft ambient glows rather than heavy drop shadows.
/// Cards sit flat on gradient/canvas layers; the dock, FAB and overlays are
/// the only elements allowed a (soft, tinted) shadow.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme;
    if (isDark) {
      // Exact tokens from the Stitch design system (designMd "Obsidian
      // Lumina"). Every value is copied verbatim — no recomputation drift.
      scheme = ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFFC0C1FF),
        onPrimary: const Color(0xFF1000A9),
        primaryContainer: const Color(0xFF8083FF),
        onPrimaryContainer: const Color(0xFF0D0096),
        secondary: const Color(0xFF4EDEA3),
        onSecondary: const Color(0xFF003824),
        secondaryContainer: const Color(0xFF00A572),
        onSecondaryContainer: const Color(0xFF00311F),
        tertiary: const Color(0xFFFFB2B7),
        onTertiary: const Color(0xFF67001B),
        tertiaryContainer: const Color(0xFFFF516A),
        onTertiaryContainer: const Color(0xFF5B0017),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        errorContainer: const Color(0xFF93000A),
        onErrorContainer: const Color(0xFFFFDAD6),
        surface: AppColors.surfaceFor(brightness),
        onSurface: AppColors.textPrimaryFor(brightness),
        surfaceContainerHighest: AppColors.surfaceContainerHighestFor(
          brightness,
        ),
        surfaceContainerHigh: AppColors.surfaceHighFor(brightness),
        surfaceContainer: AppColors.surfaceContainerFor(brightness),
        surfaceContainerLow: AppColors.surfaceSoftFor(brightness),
        surfaceContainerLowest: AppColors.surfaceLowestFor(brightness),
        onSurfaceVariant: AppColors.textSecondaryFor(brightness),
        outline: const Color(0xFF908FA0),
        outlineVariant: AppColors.borderSubtleFor(brightness),
        inverseSurface: const Color(0xFFE4E1E9),
        onInverseSurface: const Color(0xFF303035),
        inversePrimary: const Color(0xFF494BD6),
        surfaceTint: Colors.transparent,
      );
    } else {
      // Light: seed-native Material scheme (coherent violet family), with the
      // neutral roles pointed at the adapted obsidian scale in [AppColors].
      scheme = ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: brightness,
      ).copyWith(
        surface: AppColors.surfaceFor(brightness),
        surfaceContainerHighest: AppColors.surfaceContainerHighestFor(
          brightness,
        ),
        surfaceContainerHigh: AppColors.surfaceHighFor(brightness),
        surfaceContainer: AppColors.surfaceContainerFor(brightness),
        surfaceContainerLow: AppColors.surfaceSoftFor(brightness),
        surfaceContainerLowest: AppColors.surfaceLowestFor(brightness),
        onSurface: AppColors.textPrimaryFor(brightness),
        onSurfaceVariant: AppColors.textSecondaryFor(brightness),
        outlineVariant: AppColors.borderSubtleFor(brightness),
        surfaceTint: Colors.transparent,
      );
    }

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      // `copyWith(textTheme:)` *replaces* the scale rather than merging it, so
      // the family has to be re-applied here — otherwise the bundled font
      // never reaches the widgets and everything silently falls back to the
      // platform font (asserted by `app_text_styles_test.dart`).
      textTheme: AppTextStyles.textTheme.apply(
        fontFamily: AppTextStyles.fontFamily,
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.55),
        thickness: 1,
        space: 1,
      ),
      // The shell draws its own floating dock (Phase 13); this theme only
      // exists so any stray NavigationBar still looks at home on the dark
      // canvas instead of flashing Material's default light bar.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          final bool selected = states.contains(WidgetState.selected);
          return AppTextStyles.textTheme.labelSmall!.copyWith(
            fontFamily: AppTextStyles.fontFamily,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // 48px is the minimum comfortable tap target (P5-T3).
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerLow : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: const CircleBorder(),
        elevation: 0,
        highlightElevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: AppTextStyles.textTheme.labelMedium!.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          color: scheme.onSurfaceVariant,
        ),
      ),
      // Overlays float, so they keep a soft shadow and the fixed modal radius.
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
        elevation: AppElevation.overlay,
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
        elevation: AppElevation.overlay,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: AppTextStyles.textTheme.bodyMedium!.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          color: scheme.onSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
      ),
    );
  }
}
