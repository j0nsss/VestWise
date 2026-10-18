import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_motion.dart';

void main() {
  test('every motion token stays inside the ~250ms budget (P5-T1)', () {
    const Map<String, Duration> tokens = <String, Duration>{
      'pageTransition': AppMotion.pageTransition,
      'listItemEnter': AppMotion.listItemEnter,
      'stateChange': AppMotion.stateChange,
    };

    for (final MapEntry<String, Duration> token in tokens.entries) {
      expect(
        token.value.inMilliseconds,
        greaterThan(0),
        reason: '${token.key} must animate',
      );
      expect(
        token.value.inMilliseconds,
        lessThanOrEqualTo(AppMotion.maxDuration.inMilliseconds),
        reason: '${token.key} exceeds the ${AppMotion.maxDuration.inMilliseconds}ms budget',
      );
    }
  });
}
