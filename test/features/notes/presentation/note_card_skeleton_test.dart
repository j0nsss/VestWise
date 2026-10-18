import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_card_skeleton.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_list_tile.dart';

import '../../../helpers/scroll_contexts.dart';

NoteModel _note() => NoteModel()
  ..id = 1
  ..title = 'Grocery list'
  ..contentJson = '{}'
  ..contentPlainText =
      'Milk, eggs, bread and a long enough preview that the row wraps onto a '
      'second line the way it will for a real note in the list'
  ..createdAt = DateTime(2026, 3, 1)
  ..updatedAt = DateTime(2026, 3, 1);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  ),
);

void main() {
  group('NoteCardSkeleton (P11-T1)', () {
    testWidgets('occupies the same row the real note will', (
      WidgetTester tester,
    ) async {
      await _pump(tester, NoteListTile(note: _note()));
      final double real = tester.getSize(find.byType(NoteListTile)).height;

      await _pump(tester, const NoteCardSkeleton());
      final double skeleton = tester
          .getSize(find.byType(NoteCardSkeleton))
          .height;

      expect(
        (real - skeleton).abs(),
        lessThanOrEqualTo(3),
        reason: 'real $real vs skeleton $skeleton',
      );
    });

    testWidgets('survives the scroll contexts that bit this project once', (
      WidgetTester tester,
    ) async {
      await expectSurvivesScrollContexts(
        tester,
        const NoteCardSkeleton(),
        NoteCardSkeleton,
      );
    });
  });
}
