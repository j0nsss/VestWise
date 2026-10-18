import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_sparkline.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  group('VWSparkline geometry (P10-FIN-2)', () {
    test('no data produces no points, not a crash', () {
      expect(VWSparkline.normalizedPoints(const <double>[]), isEmpty);
    });

    test('a flat week sits on the midline', () {
      for (final Offset point in VWSparkline.normalizedPoints(const <double>[
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ])) {
        expect(point.dy, 0.5);
      }
    });

    test(
      'the scale is anchored at zero, so a flat gain still reads as a gain',
      () {
        final List<Offset> points = VWSparkline.normalizedPoints(const <double>[
          1000,
          1000,
          1000,
        ]);

        for (final Offset point in points) {
          expect(point.dy, lessThan(0.5));
        }
      },
    );

    test('positive values sit above the midline and negatives below', () {
      final List<Offset> points = VWSparkline.normalizedPoints(const <double>[
        10,
        -10,
        10,
      ]);

      expect(points[1].dy, greaterThan(0.5));
      expect(points[0].dy, lessThan(points[1].dy));
    });

    test('points are evenly spread across the full width', () {
      final List<Offset> points = VWSparkline.normalizedPoints(const <double>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
      ]);

      expect(points.first.dx, 0);
      expect(points.last.dx, 1);
      expect(points[3].dx, closeTo(0.5, 0.0001));
    });

    test('a single value is centred, not divided by zero', () {
      final List<Offset> points = VWSparkline.normalizedPoints(const <double>[
        42,
      ]);

      expect(points, hasLength(1));
      expect(points.single.dx, 0.5);
    });
  });

  group('VWSparkline rendering (P10-FIN-2)', () {
    testWidgets('renders a freshly installed week without throwing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const VWSparkline(values: <double>[])));

      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders seven days of mixed signs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const VWSparkline(values: <double>[120, -40, 0, 15.5, -3, 200, -80]),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(VWSparkline)).height, 36);
    });

    testWidgets('takes its colour from the last value', (
      WidgetTester tester,
    ) async {
      for (final (double last, Color Function(Brightness) expected) scenario
          in <(double, Color Function(Brightness))>[
            (50, AppColors.incomeFor),
            (-50, AppColors.expenseFor),
          ]) {
        await tester.pumpWidget(
          _wrap(VWSparkline(values: <double>[0, scenario.$1])),
        );

        final VWSparkline sparkline = tester.widget<VWSparkline>(
          find.byType(VWSparkline),
        );
        expect(sparkline.color, isNull, reason: 'the default is theme-derived');

        final CustomPaint paint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(VWSparkline),
            matching: find.byType(CustomPaint),
          ),
        );
        expect(paint.painter, isNotNull);
      }
    });

    testWidgets('renders in both themes', (WidgetTester tester) async {
      for (final Brightness brightness in Brightness.values) {
        await tester.pumpWidget(
          _wrap(
            const VWSparkline(values: <double>[1, -2, 3]),
            brightness: brightness,
          ),
        );

        expect(tester.takeException(), isNull);
      }
    });
  });
}
