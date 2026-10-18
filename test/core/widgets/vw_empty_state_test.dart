import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import '../../helpers/scroll_contexts.dart';

/// The shape Finance puts its empty state in: a card sliver above, and the
/// empty state filling whatever viewport is left. This is §1.4 #1's crash
/// site, pinched down to one test.
Widget _financeStyleHost(Widget child) => CustomScrollView(
  slivers: <Widget>[
    const SliverToBoxAdapter(child: SizedBox(height: 120, child: Card())),
    SliverFillRemaining(child: child),
  ],
);

Finder _softDisc() => find.byWidgetPredicate(
  (Widget widget) =>
      widget is Container &&
      widget.decoration is BoxDecoration &&
      (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
  description: 'the soft circular icon container',
);

void main() {
  group('VWEmptyState (P11-T3)', () {
    testWidgets('survives the scroll contexts that already crashed once', (
      WidgetTester tester,
    ) async {
      await expectSurvivesScrollContexts(
        tester,
        const VWEmptyState(message: 'Nothing here yet'),
        VWEmptyState,
      );
    });

    testWidgets('survives the Finance-empty sliver composition', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: _financeStyleHost(
              const VWEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No transactions yet',
                message:
                    'Log your first income or expense to see your balance.',
                actionLabel: 'Add transaction',
                onAction: _noop,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.text('Add transaction'), findsOneWidget);
    });

    testWidgets('a long message scrolls instead of overflowing', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: VWEmptyState(
              title: 'A rather long title to take up room',
              message: 'A long message. ' * 40,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the glyph sits in a soft disc, not loose on the page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: VWEmptyState(message: 'Nothing here yet')),
        ),
      );

      final Finder disc = _softDisc();
      expect(disc, findsOneWidget);
      expect(
        (tester.widget<Container>(disc).decoration! as BoxDecoration).color,
        AppColors.surfaceSoftFor(Brightness.light),
      );
      expect(
        find.descendant(of: disc, matching: find.byIcon(Icons.inbox_outlined)),
        findsOneWidget,
      );
    });

    testWidgets('the disc is the theme tint in dark mode too', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: VWEmptyState(message: 'Nothing here yet')),
        ),
      );

      expect(
        (tester.widget<Container>(_softDisc()).decoration! as BoxDecoration)
            .color,
        AppColors.surfaceSoftFor(Brightness.dark),
      );
    });

    testWidgets('the glyph stays out of the semantics tree', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: VWEmptyState(message: 'No tasks yet')),
        ),
      );

      // Decorative only: a screen reader should read the message, once.
      expect(find.bySemanticsLabel('No tasks yet'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the CTA is optional', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: VWEmptyState(message: 'No documents')),
        ),
      );

      expect(find.text('No documents'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}

void _noop() {}
