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
abstract final class AppRadii {
  static const double cardValue = 16;
  static const double inputValue = 12;
  static const double sheetValue = 24;

  static const BorderRadius card = BorderRadius.all(Radius.circular(cardValue));
  static const BorderRadius input = BorderRadius.all(
    Radius.circular(inputValue),
  );

  /// Top-only radius for bottom sheets, so the sheet sits flush with the
  /// bottom edge.
  static const BorderRadius sheet = BorderRadius.only(
    topLeft: Radius.circular(sheetValue),
    topRight: Radius.circular(sheetValue),
  );

  /// Fully rounded "pill" — the shape for chips and tags.
  static const BorderRadius chip = BorderRadius.all(Radius.circular(999));
}

/// Elevation policy (plan2.md P8-T2).
///
/// VestWise is flat by design: cards, list rows and grouped sections are
/// separated by a hairline border, never by a shadow. Exactly one elevated
/// value exists, and it is reserved for true overlays — dialogs, bottom sheets
/// and snackbars — which genuinely float above the page.
abstract final class AppElevation {
  /// Cards, list rows, sections.
  static const double flat = 0;

  /// Overlays only. Keep the blur small: the plan's ceiling is 8dp.
  static const double overlay = 2;

  /// The only shadow blur radius allowed anywhere in the app.
  static const double overlayBlur = 8;
}
