import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/features/notes/presentation/widgets/document_title_field.dart';
import 'package:vestwise/features/notes/presentation/widgets/last_edited_label.dart';

void main() {
  group('lastEditedLabel', () {
    final DateTime now = DateTime(2026, 3, 10, 12);

    test('reads as "just now" under a minute', () {
      expect(lastEditedLabel(now, now: now), 'just now');
      expect(
        lastEditedLabel(now.subtract(const Duration(seconds: 59)), now: now),
        'just now',
      );
    });

    test('counts minutes, then hours, then days', () {
      expect(
        lastEditedLabel(now.subtract(const Duration(minutes: 12)), now: now),
        '12m ago',
      );
      expect(
        lastEditedLabel(now.subtract(const Duration(hours: 3)), now: now),
        '3h ago',
      );
      expect(
        lastEditedLabel(now.subtract(const Duration(days: 2)), now: now),
        '2d ago',
      );
    });

    test('a week or more old falls back to a date', () {
      final String label =
          lastEditedLabel(DateTime(2026, 2, 1, 9, 30), now: now);

      expect(label, 'Feb 1, 2026');
    });

    test('a timestamp in the future does not produce a negative age', () {
      expect(
        lastEditedLabel(now.add(const Duration(hours: 4)), now: now),
        'just now',
      );
    });
  });

  group('document header widgets (P10-NOTES-1)', () {
    testWidgets('the title field is borderless until focused', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentTitleField(controller: TextEditingController()),
          ),
        ),
      );

      InputDecoration decoration() =>
          tester.widget<TextField>(find.byType(TextField)).decoration!;

      expect(decoration().border, InputBorder.none);
      expect(decoration().enabledBorder, InputBorder.none);
      expect(decoration().focusedBorder, isA<UnderlineInputBorder>());

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(decoration().focusedBorder, isA<UnderlineInputBorder>());
    });

    testWidgets('the title field shows the Untitled hint and grows', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentTitleField(controller: controller),
          ),
        ),
      );

      expect(find.text('Untitled'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, isNull);
    });

    testWidgets('the last-edited line is muted', (WidgetTester tester) async {
      final DateTime updatedAt = DateTime.now().subtract(
        const Duration(hours: 2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LastEditedLabel(updatedAt: updatedAt)),
        ),
      );

      expect(find.text('Edited 2h ago'), findsOneWidget);
    });
  });
}
