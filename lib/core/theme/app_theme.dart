import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_text_styles.dart';

/// Builds the light and dark [ThemeData] — Phase 14 ("Omotive Style"), the
/// newest screen set in the Stitch project, replacing Phase 13's Obsidian
/// Lumina mapping.
///
/// Dark is dark-first and *exact*: every role below is a token from the Omotive
/// generation (warm near-black canvases, pistachio/amber/coral card fills).
/// Light is the warm adaptation of the same trio, hand-built rather than seeded
/// — a seeded scheme would drift the accents away from the design's pistachio
/// and amber, and the ThemeMode toggle in Settings has to stay faithful.
///
/// Elevation policy (revises plan2.md P8-T2, see [AppElevation]): neutral cards
/// stay flat, coloured tactile cards carry a soft fill-tinted lift, and the
/// floating dock is the one truly hovering layer.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Exact tokens from the Omotive screens; light is the warm adaptation. No
    // recomputation, no seed drift.
    final ColorScheme scheme = isDark
        ? ColorScheme(
            brightness: Brightness.dark,
            primary: const Color(0xFFF8FFDD),
            onPrimary: const Color(0xFF283500),
            primaryContainer: AppColors.pistachio,
            onPrimaryContainer: AppColors.pistachioDeep,
            secondary: AppColors.amber,
            onSecondary: AppColors.amberDeep,
            secondaryContainer: const Color(0xFF7D5F00),
            onSecondaryContainer: const Color(0xFFFFDC90),
            tertiary: const Color(0xFFFFFAF9),
            onTertiary: const Color(0xFF670509),
            tertiaryContainer: AppColors.coral,
            onTertiaryContainer: AppColors.coralDeep,
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
            outline: const Color(0xFF909283),
            outlineVariant: AppColors.borderSubtleFor(brightness),
            inverseSurface: const Color(0xFFE4E2E4),
            onInverseSurface: const Color(0xFF303032),
            inversePrimary: const Color(0xFF55642A),
            surfaceTint: Colors.transparent,
          )
        : ColorScheme(
            brightness: Brightness.light,
            primary: AppColors.pistachioDeep,
            onPrimary: const Color(0xFFFDFFF5),
            primaryContainer: AppColors.pistachio,
            onPrimaryContainer: const Color(0xFF3D4C14),
            secondary: const Color(0xFF7D5F00),
            onSecondary: const Color(0xFFFFFCF2),
            secondaryContainer: const Color(0xFFFFDF9A),
            onSecondaryContainer: const Color(0xFF3F2E00),
            tertiary: const Color(0xFF871F1D),
            onTertiary: const Color(0xFFFFFBF9),
            tertiaryContainer: AppColors.coral,
            onTertiaryContainer: AppColors.coralDeep,
            error: const Color(0xFFBA1A1A),
            onError: const Color(0xFFFFFFFF),
            errorContainer: const Color(0xFFFFDAD6),
            onErrorContainer: const Color(0xFF93000A),
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
            outline: const Color(0xFF6E7160),
            outlineVariant: AppColors.borderSubtleFor(brightness),
            inverseSurface: const Color(0xFF303032),
            onInverseSurface: const Color(0xFFE4E2E4),
            inversePrimary: AppColors.pistachio,
            surfaceTint: Colors.transparent,
          );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      // `copyWith(textTheme:)` *replaces* rather than merges the default scale,
      // so the family has to be re-applied here — otherwise the bundled font
      // never reaches the widgets and everything silently falls back to the
      // platform font (asserted by `app_text_styles_test.dart`).
      textTheme: AppTextStyles.textTheme.apply(
        fontFamily: AppTextStyles.fontFamily,
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.row),
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
      // The shell draws its own floating dock (Phase 14, amber active circle);
      // this theme only exists so any stray NavigationBar still looks at home
      // on the warm canvas instead of flashing Material's default light bar.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: scheme.secondary,
        indicatorShape: const CircleBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onSecondary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          final bool selected = states.contains(WidgetState.selected);
          return AppTextStyles.textTheme.labelSmall!.copyWith(
            fontFamily: AppTextStyles.fontFamily,
            color: selected ? scheme.secondary : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // 48px is the minimum comfortable tap target (P5-T3); the Omotive
          // pills paint their 40px capsule *inside* this target rather than
          // shrinking it.
          minimumSize: const Size(0, 48),
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
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
          borderSide: BorderSide(color: scheme.secondary, width: 1.5),
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
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: const CircleBorder(),
        elevation: AppElevation.tactile,
        highlightElevation: AppElevation.tactile,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
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
