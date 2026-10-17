import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_section_header.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('VWCard renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const VWCard(child: Text('inside'))));
    expect(find.text('inside'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('VWButton renders its label and fires onPressed', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      _wrap(VWButton(label: 'Save', onPressed: () => tapped = true)),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(tapped, isTrue);
  });

  testWidgets('VWButton variants and loading state render', (
    WidgetTester tester,
  ) async {
    for (final VWButtonVariant variant in VWButtonVariant.values) {
      await tester.pumpWidget(
        _wrap(VWButton(label: 'Go', variant: variant, onPressed: () {})),
      );
      expect(find.text('Go'), findsOneWidget);
    }

    await tester.pumpWidget(
      _wrap(const VWButton(label: 'Saving', isLoading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Saving'), findsNothing);
  });

  testWidgets('VWTextField shows label, hint and error text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const VWTextField(label: 'Amount', hint: '0.00', errorText: 'Required'),
      ),
    );

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('VWEmptyState shows message and optional CTA', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        VWEmptyState(
          message: 'No tasks yet',
          title: 'All clear',
          actionLabel: 'Add task',
          onAction: () {},
        ),
      ),
    );

    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('All clear'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
  });

  testWidgets('VWSectionHeader shows title and trailing action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        VWSectionHeader(
          title: 'Today',
          actionLabel: 'See all',
          onAction: () {},
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
  });

  testWidgets('VWAppBar shows its title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          appBar: VWAppBar(title: 'Tasks'),
          body: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Tasks'), findsOneWidget);
  });

  testWidgets('VWLoadingIndicator shows a spinner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(const VWLoadingIndicator(message: 'Loading')));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
  });
}
