import 'package:flutter/material.dart';

/// Brand, semantic and neutral colours — Phase 14 ("Omotive Style", the
/// newest screen set in the Stitch project), replacing Phase 13's
/// "Obsidian Lumina" violet palette.
///
/// The Omotive screens are a *tactile stationery* language: near-black warm
/// neutral canvases (`#131315`), and full-colour cards in pistachio, amber and
/// coral that carry their own contrast — the card is the accent, not a tinted
/// panel with a glowing border.
///
/// Three separate concerns, deliberately kept apart:
///
/// * The neutral scale ([surfaceFor] … [borderSubtleFor]) is the canvas ladder
///   the theme maps onto Material's surface roles in `app_theme.dart`, so
///   widgets can keep reading `Theme.of(context)`.
/// * The accent trio ([pistachio], [amber], [coral]) are the design's
///   `primary-container` / `secondary` / `tertiary-container` card fills, each
///   with a `…Deep` partner for text on that fill.
/// * [incomeFor] / [expenseFor] return a brightness-appropriate tone that
///   clears 4.5:1, and every money figure, sign and bar uses those.
///   `test/core/constants/app_colors_test.dart` asserts the ratios.
abstract final class AppColors {
  /// Brand seed — the design's pistachio primary container. Only used where a
  /// single seed still has to be produced (light-scheme derivation in tests).
  static const Color seed = Color(0xFFD4E79E);

  static const Color incomeGreen = Color(0xFF16A34A);
  static const Color expenseRed = Color(0xFFDC2626);

  /// Productivity coral — urgent queues, high priority.
  static const Color priorityHigh = Color(0xFFAC3B35);

  /// Warm amber — medium priority, budget thresholds.
  static const Color priorityMedium = Color(0xFF7D5F00);

  /// Sage olive — low priority, quiet metadata.
  static const Color priorityLow = Color(0xFF58682D);

  /// Olive green — 8.5:1 on the light card surface.
  static const Color incomeGreenLight = Color(0xFF3D4C14);

  /// Brick coral — 8.6:1 on the light card surface.
  static const Color expenseRedLight = Color(0xFF871F1D);

  /// Pistachio (design `primary-fixed-dim`) — 7.4:1 on the dark card surface.
  static const Color incomeGreenDark = Color(0xFFBCCE88);

  /// Light coral (design `tertiary-fixed-dim`) — 7.4:1 on the dark card.
  static const Color expenseRedDark = Color(0xFFFFB4AC);

  /// Income colour safe for text on the current surface.
  static Color incomeFor(Brightness brightness) =>
      brightness == Brightness.dark ? incomeGreenDark : incomeGreenLight;

  /// Expense colour safe for text on the current surface.
  static Color expenseFor(Brightness brightness) =>
      brightness == Brightness.dark ? expenseRedDark : expenseRedLight;

  // ---------------------------------------------------------------------------
  // Canvas ladder (Phase 14). Dark values are verbatim from the Omotive
  // screens' generated palette; light values are the warm adaptation of the
  // same hues, so the retained ThemeMode toggle keeps working. Every text tier
  // clears 4.5:1 against the surfaces it can be painted on, asserted in
  // `app_colors_test.dart`.
  // ---------------------------------------------------------------------------

  static const Color surfaceLight = Color(0xFFFBFAF4);
  /// Omotive base canvas — warm near-black, "never pure black".
  static const Color surfaceDark = Color(0xFF131315);

  /// The tier behind grouped sections and inset strips (`surface-container-low`).
  static const Color surfaceSoftLight = Color(0xFFF4F3EC);
  static const Color surfaceSoftDark = Color(0xFF1B1B1D);

  /// The raised surface behind cards — `surface-container` in the generation.
  ///
  /// `surfaceContainerHighest` keeps its plan2-era name for API compatibility
  /// but now carries the design's `surface-container-highest` value.
  static const Color surfaceContainerHighestLight = Color(0xFFDEDDCF);
  static const Color surfaceContainerHighestDark = Color(0xFF353437);

  /// `surface-container` — the card tier the kit paints on.
  static const Color surfaceContainerLight = Color(0xFFEFEEE6);
  static const Color surfaceContainerDark = Color(0xFF1F1F21);

  /// `surface-container-high` — nested panels, unselected capsules, list rows.
  static const Color surfaceHighLight = Color(0xFFE7E6DC);
  static const Color surfaceHighDark = Color(0xFF2A2A2C);

  /// `surface-container-lowest` — meter tracks, deep insets, facepile rings.
  static const Color surfaceLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceLowestDark = Color(0xFF0E0E10);

  /// `surface-bright` — hover / pressed states on containers.
  static const Color surfaceBrightLight = Color(0xFFFFFFFF);
  static const Color surfaceBrightDark = Color(0xFF39393B);

  /// 15.4:1 (light) / 13.6:1 (dark) on the card surface.
  static const Color textPrimaryLight = Color(0xFF1D1F17);
  /// Design `on-surface` #E4E2E4.
  static const Color textPrimaryDark = Color(0xFFE4E2E4);

  /// 8.6:1 (light) / 9.9:1 (dark) on the card surface.
  static const Color textSecondaryLight = Color(0xFF4A4D3F);
  /// Design `on-surface-variant` #C6C8B8.
  static const Color textSecondaryDark = Color(0xFFC6C8B8);

  /// 6.4:1 (light) / 7.6:1 (dark) on the page, still 4.9:1 on the raised
  /// `surfaceContainerHighest` row — the dimmest tier that clears WCAG AA on
  /// every surface it can land on. Brighter than the design's decorative
  /// `outline` #909283, which is reserved for dividers and disabled glyphs.
  static const Color textTertiaryLight = Color(0xFF5A5D51);
  static const Color textTertiaryDark = Color(0xFFA5A795);

  /// Hairline border. Deliberately *decorative*, the same role `outlineVariant`
  /// plays in the card theme, so WCAG's 3:1 non-text rule does not apply.
  static const Color borderSubtleLight = Color(0xFFCFCFC0);
  /// Design `outline-variant` #45483C.
  static const Color borderSubtleDark = Color(0xFF45483C);

  static Color surfaceFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color surfaceSoftFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceSoftDark : surfaceSoftLight;

  static Color surfaceContainerFor(Brightness brightness) =>
      brightness == Brightness.dark
      ? surfaceContainerDark
      : surfaceContainerLight;

  static Color surfaceHighFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceHighDark : surfaceHighLight;

  static Color surfaceLowestFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceLowestDark : surfaceLowestLight;

  static Color surfaceBrightFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceBrightDark : surfaceBrightLight;

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
  static Color surfaceContainer(BuildContext context) =>
      surfaceContainerFor(Theme.of(context).brightness);

  /// Context-based accessor — the form every call site uses.
  static Color surfaceHigh(BuildContext context) =>
      surfaceHighFor(Theme.of(context).brightness);

  /// Context-based accessor — the form every call site uses.
  static Color borderSubtle(BuildContext context) =>
      borderSubtleFor(Theme.of(context).brightness);

  // ---------------------------------------------------------------------------
  // The tactile card trio (Phase 14). These are *fills*, not tints: the card
  // carries a saturated surface and its own ink. Every `…Deep` value is the
  // design's matching `on-…` role and clears 4.5:1 on its fill.
  // ---------------------------------------------------------------------------

  /// Pistachio card fill — the design's `primary-container` (`#D4E79E`).
  static const Color pistachio = Color(0xFFD4E79E);

  /// Ink on [pistachio] — `on-primary-container` (`#58682D`), 4.6:1.
  static const Color pistachioDeep = Color(0xFF58682D);

  /// Amber card fill — the design's `secondary` (`#EAC162`).
  static const Color amber = Color(0xFFEAC162);

  /// Ink on [amber] — `on-secondary` (`#3F2E00`), 8.6:1.
  static const Color amberDeep = Color(0xFF3F2E00);

  /// Coral card fill — the design's `tertiary-container` (`#FFD5D1`).
  static const Color coral = Color(0xFFFFD5D1);

  /// Ink on [coral] — `on-tertiary-container` (`#AC3B35`), 4.6:1.
  static const Color coralDeep = Color(0xFFAC3B35);

  /// Matte charcoal card fill — completed / passive cards.
  static const Color charcoal = Color(0xFF2A2A2C);

  /// Amber accent — the "today" capsule, the dock's active item, the pulse dot.
  /// Identical to [amber] in dark mode; kept as its own name because the
  /// semantic (an accent mark) is not the same as (a card fill).
  static const Color amberAccentLight = Color(0xFFEAC162);
  static const Color amberAccentDark = Color(0xFFEAC162);

  static Color amberAccentFor(Brightness brightness) =>
      brightness == Brightness.dark ? amberAccentDark : amberAccentLight;

  // ---------------------------------------------------------------------------
  // Tag palette (kept from plan2.md P8-T1, retinted onto the Omotive hues so
  // category chips sit inside the warm palette instead of fighting it).
  //
  // Muted pairs: a soft tinted background with a readable, darker foreground of
  // the same hue. Each pair clears 4.5:1 on its own, independently of the
  // surface it sits on.
  // ---------------------------------------------------------------------------

  static const Map<AppTag, AppTagColor> _tagsLight = <AppTag, AppTagColor>{
    AppTag.red: AppTagColor(
      background: Color(0xFFFBE3E0),
      foreground: Color(0xFF8C211B),
    ),
    AppTag.orange: AppTagColor(
      background: Color(0xFFF9E7CC),
      foreground: Color(0xFF7A4A05),
    ),
    AppTag.yellow: AppTagColor(
      background: Color(0xFFF7EFC9),
      foreground: Color(0xFF6B5500),
    ),
    AppTag.green: AppTagColor(
      background: Color(0xFFE9EED2),
      foreground: Color(0xFF3D4C14),
    ),
    AppTag.blue: AppTagColor(
      background: Color(0xFFE1E8E4),
      foreground: Color(0xFF2F4440),
    ),
    AppTag.purple: AppTagColor(
      background: Color(0xFFEFE4E9),
      foreground: Color(0xFF63313F),
    ),
    AppTag.gray: AppTagColor(
      background: Color(0xFFECEBE2),
      foreground: Color(0xFF4A4D3F),
    ),
  };

  static const Map<AppTag, AppTagColor> _tagsDark = <AppTag, AppTagColor>{
    AppTag.red: AppTagColor(
      background: Color(0xFF3E2623),
      foreground: Color(0xFFFFB4AC),
    ),
    AppTag.orange: AppTagColor(
      background: Color(0xFF3B2E17),
      foreground: Color(0xFFF0C983),
    ),
    AppTag.yellow: AppTagColor(
      background: Color(0xFF3A3418),
      foreground: Color(0xFFE7D48F),
    ),
    AppTag.green: AppTagColor(
      background: Color(0xFF2C331F),
      foreground: Color(0xFFC6D29A),
    ),
    AppTag.blue: AppTagColor(
      background: Color(0xFF262E2C),
      foreground: Color(0xFFB4CBC5),
    ),
    AppTag.purple: AppTagColor(
      background: Color(0xFF332730),
      foreground: Color(0xFFDDBFCB),
    ),
    AppTag.gray: AppTagColor(
      background: Color(0xFF2E2E2B),
      foreground: Color(0xFFCFD1C2),
    ),
  };

  static AppTagColor tagFor(AppTag tag, Brightness brightness) =>
      (brightness == Brightness.dark ? _tagsDark : _tagsLight)[tag]!;

  /// Stable index → tag mapping, so the same category keeps its chip colour
  /// across rebuilds (and wraps around if there are more categories than tags).
  static AppTagColor tagForIndex(int index, Brightness brightness) =>
      tagFor(AppTag.values[index % AppTag.values.length], brightness);

  static List<AppTagColor> tagPaletteFor(Brightness brightness) => AppTag.values
      .map((AppTag tag) => tagFor(tag, brightness))
      .toList(growable: false);

  /// The hue a label maps to — a category name, a priority, a tag.
  ///
  /// FNV-1a over the characters, so it is stable across runs and platforms:
  /// Dart's `String.hashCode` is not, and a category that changed colour on
  /// every launch would be worse than one with no colour at all. Nothing is
  /// stored, so the mapping is the same for a fresh install and an old one.
  static AppTag tagForLabel(String label) {
    int hash = 0x811c9dc5;
    for (final int unit in label.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    return AppTag.values[hash % AppTag.values.length];
  }
}

/// The hues available to the tag palette, in a fixed order.
enum AppTag { red, orange, yellow, green, blue, purple, gray }

/// A muted background/foreground pair used for chips and tags.
class AppTagColor {
  const AppTagColor({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
