import 'package:flutter/material.dart';

/// Brand, semantic and neutral colours (plan §1.5, extended by plan2.md P8-T1).
///
/// Three separate concerns, deliberately kept apart:
///
/// * [seed] is the only colour that feeds Material 3's [ColorScheme]. The warm
///   neutral scale below is mapped onto the scheme's surface/neutral roles in
///   `app_theme.dart`, so widgets can keep reading `Theme.of(context)`.
/// * The neutral scale ([surfaceFor] … [borderSubtleFor]) is the source of that
///   mapping and is also available directly for the few places that need a
///   colour outside the [ColorScheme] (e.g. a tag chip).
/// * [incomeGreen] / [expenseRed] are brand accents — they seed default
///   category colours and are *never* painted as on-surface text or as an
///   essential chart mark, because they do not clear WCAG contrast.
///   [incomeFor] / [expenseFor] return a brightness-appropriate tone that
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

  /// Green-700 — 6.25:1 on the light `surfaceContainerHighest`.
  static const Color incomeGreenLight = Color(0xFF166534);

  /// Red-800 — 5.67:1 on the light `surfaceContainerHighest`.
  static const Color expenseRedLight = Color(0xFFB91C1C);

  /// Green-400 — 8.70:1 on the dark `surfaceContainerHighest`.
  static const Color incomeGreenDark = Color(0xFF4ADE80);

  /// Red-300 — 7.99:1 on the dark `surfaceContainerHighest`.
  static const Color expenseRedDark = Color(0xFFFCA5A5);

  /// Income colour safe for text on the current surface.
  static Color incomeFor(Brightness brightness) =>
      brightness == Brightness.dark ? incomeGreenDark : incomeGreenLight;

  /// Expense colour safe for text on the current surface.
  static Color expenseFor(Brightness brightness) =>
      brightness == Brightness.dark ? expenseRedDark : expenseRedLight;

  // ---------------------------------------------------------------------------
  // Warm neutral scale (plan2.md P8-T1).
  //
  // Warm off-white/near-black rather than pure white/black — the single change
  // that makes the app read as "designed" rather than default Material. Every
  // value below clears the 4.5:1 text threshold against all three surfaces it
  // can be painted on, asserted in `app_colors_test.dart`.
  // ---------------------------------------------------------------------------

  static const Color surfaceLight = Color(0xFFFBFBFA);
  static const Color surfaceDark = Color(0xFF191918);

  /// The faint warm tint behind grouped sections and empty states — a hair
  /// darker than [surface], so a section reads as a group without a border.
  static const Color surfaceSoftLight = Color(0xFFF5F4F1);
  static const Color surfaceSoftDark = Color(0xFF232322);

  /// The raised surface behind cards.
  static const Color surfaceContainerHighestLight = Color(0xFFF3F2EE);
  static const Color surfaceContainerHighestDark = Color(0xFF262624);

  /// 10.95:1 (light) / 12.13:1 (dark) on the raised card surface.
  static const Color textPrimaryLight = Color(0xFF37352F);
  static const Color textPrimaryDark = Color(0xFFE6E6E4);

  /// 6.58:1 (light) / 7.21:1 (dark) on the raised card surface.
  static const Color textSecondaryLight = Color(0xFF57564F);
  static const Color textSecondaryDark = Color(0xFFB4B3AD);

  /// 4.62:1 (light) / 5.12:1 (dark) on the raised card surface — the dimmest
  /// tier that still clears WCAG AA.
  static const Color textTertiaryLight = Color(0xFF6F6D66);
  static const Color textTertiaryDark = Color(0xFF98968F);

  /// Hairline border used instead of elevation. Deliberately *decorative*
  /// (≈1.2:1 on the light surface), the same role `outlineVariant` plays in the
  /// card theme, so WCAG's 3:1 non-text rule does not apply to it.
  static const Color borderSubtleLight = Color(0xFFE4E3DE);
  static const Color borderSubtleDark = Color(0xFF3E3E3C);

  static Color surfaceFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color surfaceSoftFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceSoftDark : surfaceSoftLight;

  static Color surfaceContainerHighestFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? surfaceContainerHighestDark
          : surfaceContainerHighestLight;

  static Color textPrimaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  static Color textTertiaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textTertiaryDark : textTertiaryLight;

  static Color borderSubtleFor(Brightness brightness) =>
      brightness == Brightness.dark ? borderSubtleDark : borderSubtleLight;

  /// Context-based accessor — the form every call site uses.
  static Color surfaceSoft(BuildContext context) =>
      surfaceSoftFor(Theme.of(context).brightness);

  /// Context-based accessor — the form every call site uses.
  static Color borderSubtle(BuildContext context) =>
      borderSubtleFor(Theme.of(context).brightness);

  // ---------------------------------------------------------------------------
  // Tag palette (plan2.md P8-T1).
  //
  // Muted pairs for category/priority/tag chips: a soft tinted background with
  // a readable, slightly darker foreground of the same hue. Never a competing
  // saturated colour next to the brand accent. Each pair clears 4.5:1 on its
  // own, independently of the surface it sits on.
  // ---------------------------------------------------------------------------

  static const Map<AppTag, AppTagColor> _tagsLight = <AppTag, AppTagColor>{
    AppTag.red: AppTagColor(
      background: Color(0xFFFBE9E7),
      foreground: Color(0xFFB3261E),
    ),
    AppTag.orange: AppTagColor(
      background: Color(0xFFFDEBD3),
      foreground: Color(0xFF92400E),
    ),
    AppTag.yellow: AppTagColor(
      background: Color(0xFFFBF3D1),
      foreground: Color(0xFF7A5B00),
    ),
    AppTag.green: AppTagColor(
      background: Color(0xFFE4F3E4),
      foreground: Color(0xFF166534),
    ),
    AppTag.blue: AppTagColor(
      background: Color(0xFFE3EDFA),
      foreground: Color(0xFF1E4E8C),
    ),
    AppTag.purple: AppTagColor(
      background: Color(0xFFF1E9FB),
      foreground: Color(0xFF6B21A8),
    ),
    AppTag.gray: AppTagColor(
      background: Color(0xFFEDECE8),
      foreground: Color(0xFF4A4944),
    ),
  };

  static const Map<AppTag, AppTagColor> _tagsDark = <AppTag, AppTagColor>{
    AppTag.red: AppTagColor(
      background: Color(0xFF3A2320),
      foreground: Color(0xFFF2B8B5),
    ),
    AppTag.orange: AppTagColor(
      background: Color(0xFF3A2A18),
      foreground: Color(0xFFF5C48A),
    ),
    AppTag.yellow: AppTagColor(
      background: Color(0xFF3A3318),
      foreground: Color(0xFFE8D48A),
    ),
    AppTag.green: AppTagColor(
      background: Color(0xFF1E3324),
      foreground: Color(0xFFA8D5A8),
    ),
    AppTag.blue: AppTagColor(
      background: Color(0xFF1E2C40),
      foreground: Color(0xFFA8C7ED),
    ),
    AppTag.purple: AppTagColor(
      background: Color(0xFF2C2440),
      foreground: Color(0xFFCBB8ED),
    ),
    AppTag.gray: AppTagColor(
      background: Color(0xFF2E2E2C),
      foreground: Color(0xFFCFCEC8),
    ),
  };

  static AppTagColor tagFor(AppTag tag, Brightness brightness) =>
      (brightness == Brightness.dark ? _tagsDark : _tagsLight)[tag]!;

  /// Stable index → tag mapping, so the same category keeps its chip colour
  /// across rebuilds (and wraps around if there are more categories than tags).
  static AppTagColor tagForIndex(int index, Brightness brightness) =>
      tagFor(AppTag.values[index % AppTag.values.length], brightness);

  static List<AppTagColor> tagPaletteFor(Brightness brightness) =>
      AppTag.values
          .map((AppTag tag) => tagFor(tag, brightness))
          .toList(growable: false);
}

/// The hues available to the tag palette, in a fixed order.
enum AppTag { red, orange, yellow, green, blue, purple, gray }

/// A muted background/foreground pair used for chips and tags.
class AppTagColor {
  const AppTagColor({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
