import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_icon_picker.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_list_tile.dart';

NoteModel _note({int? iconCodePoint}) => NoteModel()
  ..id = 1
  ..title = 'Groceries'
  ..contentJson = '[]'
  ..iconCodePoint = iconCodePoint
  ..createdAt = DateTime(2026, 3, 1)
  ..updatedAt = DateTime(2026, 3, 2);

void main() {
  group('noteIconFor', () {
    test('defaults to a document when no icon was ever chosen', () {
      expect(noteIconFor(null), Icons.description_outlined);
    });

    test('resolves a persisted code point back to its icon', () {
      expect(
        noteIconFor(Icons.travel_explore_outlined.codePoint),
        Icons.travel_explore_outlined,
      );
    });

    test('every offered option is distinct and labelled', () {
      final Set<int> codePoints = noteIconOptions
          .map((NoteIconOption option) => option.icon.codePoint)
          .toSet();
      final Set<String> labels = noteIconOptions
          .map((NoteIconOption option) => option.label)
          .toSet();

      expect(codePoints, hasLength(noteIconOptions.length));
      expect(labels, hasLength(noteIconOptions.length));
      expect(
        noteIconOptions.every(
          (NoteIconOption option) => option.label.trim().isNotEmpty,
        ),
        isTrue,
      );
    });
  });

  group('NoteIconPicker', () {
    testWidgets('pops the icon the user tapped', (WidgetTester tester) async {
      IconData? picked;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  picked = await showModalBottomSheet<IconData>(
                    context: context,
                    builder: (BuildContext context) => const NoteIconPicker(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Choose an icon'), findsOneWidget);

      await tester.tap(find.byTooltip('Idea'));
      await tester.pumpAndSettle();

      expect(picked, Icons.lightbulb_outline);
    });

    testWidgets('every option is reachable by its label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: NoteIconPicker()),
        ),
      );

      for (final NoteIconOption option in noteIconOptions) {
        expect(find.byTooltip(option.label), findsOneWidget);
      }
    });

    testWidgets('a dismissed sheet chooses nothing', (
      WidgetTester tester,
    ) async {
      bool completed = false;
      IconData? picked;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  picked = await showModalBottomSheet<IconData>(
                    context: context,
                    builder: (BuildContext context) => const NoteIconPicker(),
                  );
                  completed = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // Tap the barrier above the sheet.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(picked, isNull);
    });
  });

  group('NoteListTile icon (P10-NOTES-2)', () {
    testWidgets('shows no leading icon when none was chosen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: NoteListTile(note: _note())),
        ),
      );

      // Phase 13: the tile is a card rather than a ListTile — with no icon
      // chosen, the only icon drawn on the row is the pin affordance.
      expect(find.byType(Icon), findsOneWidget);
      expect(tester.widget<Icon>(find.byType(Icon)).icon, Icons.push_pin_outlined);
    });

    testWidgets('shows the chosen icon when there is one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: NoteListTile(
              note: _note(iconCodePoint: Icons.star_outline.codePoint),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_outline), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsNothing);
    });
  });
}
