import 'package:flutter/widgets.dart';

/// Spacing scale from plan §1.5. Use these exclusively — no magic numbers.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Shared corner radii from plan §1.5 — defined once, referenced everywhere.
///
/// Phase 14 (Omotive) widened the ladder: the tactile coloured cards are the
/// softest shape in the app (28), list rows sit at 24, and tiles/panels keep
/// the 16 the plan started with. Pills stay fully round.
abstract final class AppRadii {
  static const double cardValue = 16;
  static const double inputValue = 12;
  static const double sheetValue = 24;

  /// Coloured tactile cards (balance, task, event, expense blocks).
  static const double tactileValue = 28;

  /// List rows and telemetry rows.
  static const double rowValue = 24;

  static const BorderRadius card = BorderRadius.all(Radius.circular(cardValue));
  static const BorderRadius input = BorderRadius.all(
    Radius.circular(inputValue),
  );

  /// The softest corner in the app — the tactile card.
  static const BorderRadius tactile = BorderRadius.all(
    Radius.circular(tactileValue),
  );

  /// List-row radius.
  static const BorderRadius row = BorderRadius.all(Radius.circular(rowValue));

  /// Top-only radius for bottom sheets, so the sheet sits flush with the
  /// bottom edge.
  static const BorderRadius sheet = BorderRadius.only(
    topLeft: Radius.circular(sheetValue),
    topRight: Radius.circular(sheetValue),
  );

  /// Fully rounded "pill" — the shape for chips and tags.
  static const BorderRadius chip = BorderRadius.all(Radius.circular(999));
}

/// Elevation policy (plan2.md P8-T2, revised by Phase 14 / Omotive).
///
/// plan2 made the app flat: cards separated by a hairline, shadows reserved
/// for overlays. Omotive keeps cards flat *except* the coloured tactile ones,
/// which the design lifts with a soft shadow tinted by their own fill — a flat
/// pistachio block reads like a swatch, a lifted one reads as a card. The
/// floating dock gets the deepest shadow in the app, because it genuinely
/// hovers over scrolling content.
abstract final class AppElevation {
  /// Neutral cards, list rows, sections.
  static const double flat = 0;

  /// Coloured tactile cards — a soft, fill-tinted lift.
  static const double tactile = 6;

  /// Blur for [tactile]; paired with `alpha ≈ 0.2` of the card's own colour.
  static const double tactileBlur = 24;

  /// The floating dock, the highest layer in the app.
  static const double dock = 12;

  /// Blur for [dock].
  static const double dockBlur = 32;

  /// Overlays — dialogs, sheets, snackbars.
  static const double overlay = 2;

  /// The blur allowed for overlays; the plan's ceiling is 8dp.
  static const double overlayBlur = 8;
}
