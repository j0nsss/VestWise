import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/widgets/vw_delayed.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('VWDelayed (P11-T2)', () {
    testWidgets('shows nothing until the delay has passed', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const VWDelayed(child: Text('placeholder')));

      expect(find.text('placeholder'), findsNothing);

      await tester.pump(const Duration(milliseconds: 50));
      expect(
        find.text('placeholder'),
        findsNothing,
        reason: 'halfway is still nothing',
      );

      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('placeholder'), findsOneWidget);
    });

    testWidgets('appears on the very next frame once the delay is up', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const VWDelayed(
          delay: Duration(milliseconds: 20),
          child: Text('placeholder'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 25));
      expect(find.text('placeholder'), findsOneWidget);
    });

    testWidgets('content arriving first means no placeholder ever shows', (
      WidgetTester tester,
    ) async {
      // This is the whole point of the gate: local Isar usually answers well
      // inside the delay, so the fast path must show no skeleton at all.
      await _pump(tester, const VWDelayed(child: Text('placeholder')));
      await tester.pump(const Duration(milliseconds: 50));

      await _pump(tester, const Text('content'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('placeholder'), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('a zero delay shows the child straight away', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const VWDelayed(
          delay: Duration.zero,
          child: Text('placeholder'),
        ),
      );

      expect(find.text('placeholder'), findsOneWidget);
    });
  });
}
