import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';

/// Renders [child] in each scroll context that has already bitten this project
/// (plan2.md §1.4 #1) and asserts it lays out without throwing.
///
/// That bug was a `VWEmptyState` crashing inside a parent with unbounded
/// height. A skeleton stands in the same slot, so it has to survive the same
/// hosts — and a placeholder is exactly the kind of widget that gets written as
/// "just a Column" and only breaks once it is inside a sliver.
///
/// Never settles the tree: a shimmer animates forever by design, so these
/// hosts are pumped frame by frame rather than with `pumpAndSettle`.
Future<void> expectSurvivesScrollContexts(
  WidgetTester tester,
  Widget child,
  Type type,
) async {
  final List<(String, Widget)> hosts = <(String, Widget)>[
    (
      'a SliverList',
      CustomScrollView(
        slivers: <Widget>[
          SliverList.list(children: <Widget>[child]),
        ],
      ),
    ),
    (
      'a SliverFillRemaining without a scroll body',
      CustomScrollView(
        slivers: <Widget>[
          SliverFillRemaining(hasScrollBody: false, child: child),
        ],
      ),
    ),
    ('a plain ListView', ListView(children: <Widget>[child])),
  ];

  for (final (String name, Widget host) in hosts) {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: host),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull, reason: name);
    expect(find.byType(type), findsOneWidget, reason: name);
  }
}
