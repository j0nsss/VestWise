import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/app.dart';
import 'package:vestwise/core/theme/app_theme.dart';

void main() {
  testWidgets('VestWiseApp boots into a themed MaterialApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: VestWiseApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  test('AppTheme exposes a light and dark Material 3 theme', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });
}
