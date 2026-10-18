import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_inline_spinner.dart';

Future<void> _pump(
  WidgetTester tester, {
  VWButtonVariant variant = VWButtonVariant.primary,
  bool isLoading = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: VWButton(
          label: 'Save',
          variant: variant,
          isLoading: isLoading,
          onPressed: () {},
        ),
      ),
    ),
  );
}

void main() {
  for (final VWButtonVariant variant in VWButtonVariant.values) {
    testWidgets('${variant.name} meets the 48px tap target (P5-T3)',
        (WidgetTester tester) async {
      await _pump(tester, variant: variant);

      expect(
        tester.getSize(find.byType(VWButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  }

  testWidgets('exposes its label to assistive technology', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(tester);

    expect(find.bySemanticsLabel('Save'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('shows the shared inline spinner while loading', (
    WidgetTester tester,
  ) async {
    await _pump(tester, isLoading: true);

    expect(find.byType(VWInlineSpinner), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
}
