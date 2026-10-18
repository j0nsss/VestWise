import 'package:flutter/material.dart';

/// The single sanctioned small spinner (P5-T2). Used for inline progress such
/// as a button's busy state or an app-bar action — never construct a bare
/// [CircularProgressIndicator] in a screen.
class VWInlineSpinner extends StatelessWidget {
  const VWInlineSpinner({this.dimension = 18, this.strokeWidth = 2, super.key});

  final double dimension;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: Center(child: CircularProgressIndicator(strokeWidth: strokeWidth)),
    );
  }
}
