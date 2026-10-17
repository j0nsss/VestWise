// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

/// Builds a Material [IconData] from a persisted icon code point.
///
/// Icons are stored as ints in Isar (plan §10.1). Building [IconData] from a
/// runtime value is deliberate — the icon set is small and closed (the default
/// categories), so we accept the tree-shaking caveat the analyzer warns about.
IconData iconDataFromCodePoint(int codePoint) =>
    IconData(codePoint, fontFamily: 'MaterialIcons');
