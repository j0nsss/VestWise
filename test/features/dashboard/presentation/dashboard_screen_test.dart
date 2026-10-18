import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_sparkline.dart';
import 'package:vestwise/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:vestwise/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:vestwise/features/finance/domain/models/daily_net.dart';
import 'package:vestwise/features/finance/presentation/widgets/money.dart';

List<DailyNet> _week(List<double> nets) => <DailyNet>[
  for (int i = 0; i < nets.length; i++)
    DailyNet(day: DateTime(2026, 3, 1 + i), net: nets[i]),
];

Future<void> _pump(
  WidgetTester tester,
  DashboardState state, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dashboardProvider.overrideWith((Ref ref) => state)],
      child: MaterialApp(
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        home: const DashboardScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DashboardScreen balance card (P10-FIN-4)', () {
    testWidgets('a fresh install shows the empty state, not a zero', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const DashboardState.empty());

      expect(find.text('No transactions yet.'), findsOneWidget);
      expect(find.byType(VWEmptyState), findsWidgets);
      expect(find.byType(VWSparkline), findsNothing);
    });

    testWidgets('with data it shows balance, delta chip and the week line', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        DashboardState(
          todayTasks: const [],
          balance: 1250.5,
          weeklyNetChange: -40,
          last7DaysNet: _week(<double>[0, 10, 0, -50, 0, 0, 0]),
          hasFinanceData: true,
          upcomingEvents: const [],
          recentNotes: const [],
        ),
      );

      final ThemeData theme = AppTheme.light;
      expect(find.text(formatMoney(1250.5)), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      // Locale-safe: asserted through the app's own formatter, never a literal.
      expect(find.text('-${formatMoney(40)}'), findsWidgets);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
      expect(find.byType(VWSparkline), findsOneWidget);
      expect(find.text('No transactions yet.'), findsNothing);

      // The chip uses the expense tone's tag pair, not a hand-picked tint.
      final AppTagColor pair = AppColors.tagFor(AppTag.red, theme.brightness);
      expect(pair.foreground, isNotNull);
    });

    testWidgets('a positive week points the other way', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        DashboardState(
          todayTasks: const [],
          balance: 100,
          weeklyNetChange: 25,
          last7DaysNet: _week(<double>[0, 0, 25, 0, 0, 0, 0]),
          hasFinanceData: true,
          upcomingEvents: const [],
          recentNotes: const [],
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+${formatMoney(25)}'), findsWidgets);
    });

    testWidgets('the card is the soft variant', (WidgetTester tester) async {
      await _pump(tester, const DashboardState.empty());

      final Iterable<VWCard> cards = tester.widgetList<VWCard>(
        find.byType(VWCard),
      );

      expect(
        cards.where((VWCard card) => card.variant == VWCardVariant.soft),
        hasLength(1),
      );
    });

    testWidgets('renders in dark mode', (WidgetTester tester) async {
      await _pump(
        tester,
        DashboardState(
          todayTasks: const [],
          balance: 10,
          weeklyNetChange: 0,
          last7DaysNet: _week(<double>[0, 0, 0, 0, 0, 0, 0]),
          hasFinanceData: true,
          upcomingEvents: const [],
          recentNotes: const [],
        ),
        brightness: Brightness.dark,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(VWSparkline), findsOneWidget);
    });
  });
}
