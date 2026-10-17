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

  static const BorderRadius card = BorderRadius.all(Radius.circular(cardValue));
  static const BorderRadius input =
      BorderRadius.all(Radius.circular(inputValue));
}
