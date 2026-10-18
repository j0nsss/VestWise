import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_animated_list_item.dart';
import 'package:vestwise/core/widgets/vw_fade_through.dart';
import 'package:vestwise/core/widgets/vw_staggered_list.dart';

Widget _wrap(Widget child, {bool reduce = false}) => MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduce),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('VWFadeThrough (P9-T2)', () {
    testWidgets('cross-fades when the child changes', (
      WidgetTester tester,
    ) async {
      Widget build(String label) =>
          _wrap(VWFadeThrough(child: Text(label, key: ValueKey(label))));

      await tester.pumpWidget(build('list'));
      expect(find.text('list'), findsOneWidget);

      await tester.pumpWidget(build('empty'));
      await tester.pump();
      // Mid-switch both are on screen, fading through each other.
      expect(find.text('list'), findsOneWidget);
      expect(find.text('empty'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('list'), findsNothing);
      expect(find.text('empty'), findsOneWidget);
    });

    testWidgets('uses a transition inside the motion budget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const VWFadeThrough(child: Text('a'))));

      final AnimatedSwitcher switcher =
          tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
      expect(switcher.duration, AppMotion.stateChange);
      expect(switcher.duration, lessThanOrEqualTo(AppMotion.maxDuration));
    });

    testWidgets('is instant under reduced motion', (WidgetTester tester) async {
      Widget build(String label) => _wrap(
            VWFadeThrough(child: Text(label, key: ValueKey(label))),
            reduce: true,
          );

      await tester.pumpWidget(build('list'));
      await tester.pumpWidget(build('empty'));

      final AnimatedSwitcher switcher =
          tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
      expect(switcher.duration, Duration.zero);

      await tester.pump();
      expect(find.text('list'), findsNothing);
      expect(find.text('empty'), findsOneWidget);
    });
  });

  group('VWStaggeredList (P9-T2)', () {
    testWidgets('renders every item without dropping any', (
      WidgetTester tester,
    ) async {
      const int count = 12;
      await tester.pumpWidget(
        _wrap(
          ListView(
            children: <Widget>[
              for (int i = 0; i < count; i++)
                VWStaggeredList(index: i, child: Text('row $i')),
            ],
          ),
        ),
      );
      // Item 0 sits at the very top and item 11 below the fold, so scroll
      // through and confirm none of them vanished into an animation wrapper.
      for (int i = 0; i < count; i++) {
        await tester.scrollUntilVisible(
          find.text('row $i'),
          60,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('row $i'), findsOneWidget);
      }

      await tester.pumpAndSettle();
    });

    testWidgets('rows past the visible count are returned untouched', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: <Widget>[
              VWStaggeredList(index: 0, child: Text('first')),
              VWStaggeredList(
                index: VWAnimatedListItem.visibleCount,
                child: Text('later'),
              ),
            ],
          ),
        ),
      );

      // Only the first row is wrapped, so a long list stays cheap to build.
      expect(find.byType(VWAnimatedListItem), findsOneWidget);
      expect(find.text('first'), findsOneWidget);
      expect(find.text('later'), findsOneWidget);
    });

    testWidgets('the stagger is short, monotonic and capped', (
      WidgetTester tester,
    ) async {
      expect(VWStaggeredList.delayFor(0), Duration.zero);
      expect(VWStaggeredList.delayFor(1), AppMotion.staggerStep);
      expect(
        VWStaggeredList.delayFor(2).inMilliseconds,
        greaterThan(VWStaggeredList.delayFor(1).inMilliseconds),
      );

      final Duration cap = VWStaggeredList.delayFor(AppMotion.staggerMaxItems);
      expect(
        VWStaggeredList.delayFor(AppMotion.staggerMaxItems + 3),
        cap,
        reason: 'rows past the cap share the last delay, they do not queue up',
      );

      final int worstCase = AppMotion.listItemEnter.inMilliseconds +
          cap.inMilliseconds;
      expect(
        worstCase,
        lessThanOrEqualTo(AppMotion.signature.inMilliseconds),
        reason: 'the last staggered row must land inside signature',
      );
    });

    testWidgets('reduced motion drops the stagger entirely', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                VWStaggeredList(index: i, child: Text('row $i')),
            ],
          ),
          reduce: true,
        ),
      );

      // VWAnimatedListItem still exists as the wrapper, but it opts out of the
      // animation, so every row is painted immediately.
      expect(find.byType(AnimatedOpacity), findsNothing);
      expect(find.byType(AnimatedSlide), findsNothing);
      for (int i = 0; i < 3; i++) {
        expect(find.text('row $i'), findsOneWidget);
      }
    });

    testWidgets('rows are visible once settled, with no stagger left running',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                VWStaggeredList(index: i, child: Text('row $i')),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      for (final AnimatedOpacity fade
          in tester.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))) {
        expect(fade.opacity, 1);
      }
    });
  });
}
