import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/domain/repositories/notes_repository.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/notes/presentation/screens/notes_list_screen.dart';
import 'package:vestwise/core/widgets/vw_section_disclosure.dart';
import 'package:vestwise/features/notes/presentation/widgets/notes_sections.dart';

class _FakeNotesRepository implements NotesRepository {
  _FakeNotesRepository(this.notes);

  final List<NoteModel> notes;

  @override
  Stream<List<NoteModel>> watchAllNotes() => Stream.value(notes);

  @override
  Stream<List<NoteModel>> watchNotesMatching(String query) => Stream.value(
        query.isEmpty
            ? notes
            : notes
                .where(
                  (NoteModel note) => note.title
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList(),
      );

  @override
  Stream<List<ImportedDocumentModel>> watchImportedDocuments() =>
      Stream.value(const <ImportedDocumentModel>[]);

  @override
  Future<Result<void>> updateNote(NoteModel note) async =>
      const Success<void>(null);

  @override
  Future<Result<NoteModel>> getNoteById(int id) async =>
      Success<NoteModel>(notes.firstWhere((NoteModel n) => n.id == id));

  @override
  Future<Result<int>> createNote(NoteModel note) async => const Success<int>(1);

  @override
  Future<Result<void>> deleteNote(int id) async => const Success<void>(null);

  @override
  Future<Result<ImportedDocumentModel>> getDocumentById(int id) async =>
      const Error<ImportedDocumentModel>(UnexpectedFailure('none'));

  @override
  Future<Result<int>> createImportedDocument(ImportedDocumentModel d) async =>
      const Success<int>(1);

  @override
  Future<Result<void>> deleteImportedDocument(int id) async =>
      const Success<void>(null);
}

NoteModel _note(int id, String title, {bool pinned = false}) => NoteModel()
  ..id = id
  ..title = title
  ..contentJson = '[]'
  ..contentPlainText = ''
  ..isPinned = pinned
  ..createdAt = DateTime(2026, 3, 1)
  ..updatedAt = DateTime(2026, 3, id);

Future<void> _pumpNotes(
  WidgetTester tester, {
  required List<NoteModel> notes,
}) async {
  // No file-storage override: the Documents tab (and its size readout) is not
  // built while the Notes tab is on screen. Real dart:io work cannot be awaited
  // inside `testWidgets` anyway — the body runs in a fake-async zone, so a
  // future from the real event loop never completes.
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notesRepositoryProvider.overrideWith((Ref ref) {
          return _FakeNotesRepository(notes);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const NotesListScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('buildNoteRows', () {
    final NoteModel pinned = _note(1, 'Pinned note', pinned: true);
    final NoteModel other = _note(2, 'Other note');

    test('an unpinned library is one flat list with no headings', () {
      final List<NotesRow> rows = buildNoteRows(
        <NoteModel>[other],
        collapsed: <NotesSection>{},
      );

      expect(rows, hasLength(1));
      expect(rows.single, isA<NoteRow>());
    });

    test('pinned notes are grouped first, with counts', () {
      final List<NotesRow> rows = buildNoteRows(
        <NoteModel>[pinned, other],
        collapsed: <NotesSection>{},
      );

      expect(rows, hasLength(4));
      expect((rows[0] as SectionRow).section, NotesSection.pinned);
      expect((rows[0] as SectionRow).count, 1);
      expect((rows[1] as NoteRow).note, pinned);
      expect((rows[2] as SectionRow).section, NotesSection.others);
      expect((rows[3] as NoteRow).note, other);
    });

    test('a collapsed group keeps its heading but drops its notes', () {
      final List<NotesRow> rows = buildNoteRows(
        <NoteModel>[pinned, other],
        collapsed: <NotesSection>{NotesSection.pinned},
      );

      expect(rows, hasLength(3));
      expect((rows[0] as SectionRow).section, NotesSection.pinned);
      expect(rows[1], isA<SectionRow>());
      expect((rows[2] as NoteRow).note, other);
    });

    test('a library that is entirely pinned needs no headings', () {
      final List<NotesRow> rows = buildNoteRows(
        <NoteModel>[pinned],
        collapsed: <NotesSection>{},
      );

      expect(rows, hasLength(1));
      expect(rows.single, isA<NoteRow>());
    });

    test('searching shows matches flat, regardless of pinning', () {
      final List<NotesRow> rows = buildNoteRows(
        <NoteModel>[pinned, other],
        collapsed: <NotesSection>{},
        searching: true,
      );

      expect(rows, hasLength(2));
      expect(rows.every((NotesRow row) => row is NoteRow), isTrue);
    });
  });

  group('NotesListScreen sections (P10-NOTES-3)', () {
    testWidgets('groups pinned and other notes and collapses on tap', (
      WidgetTester tester,
    ) async {
      await _pumpNotes(
        tester,
        notes: <NoteModel>[
          _note(1, 'Pinned note', pinned: true),
          _note(2, 'Other note'),
        ],
      );

      expect(find.text('Pinned · 1'), findsOneWidget);
      expect(find.text('Others · 1'), findsOneWidget);
      expect(find.text('Pinned note'), findsOneWidget);
      expect(find.text('Other note'), findsOneWidget);

      await tester.tap(find.text('Pinned · 1'));
      await tester.pumpAndSettle();

      expect(find.text('Pinned note'), findsNothing);
      expect(find.text('Other note'), findsOneWidget);
      expect(find.text('Pinned · 1'), findsOneWidget);

      await tester.tap(find.text('Pinned · 1'));
      await tester.pumpAndSettle();

      expect(find.text('Pinned note'), findsOneWidget);
    });

    testWidgets('an unpinned library shows no headings at all', (
      WidgetTester tester,
    ) async {
      await _pumpNotes(
        tester,
        notes: <NoteModel>[_note(1, 'One'), _note(2, 'Two')],
      );

      expect(find.byType(VWSectionDisclosure), findsNothing);
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('the heading reports its state to screen readers', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pumpNotes(
        tester,
        notes: <NoteModel>[
          _note(1, 'Pinned note', pinned: true),
          _note(2, 'Other note'),
        ],
      );

      expect(
        tester.getSemantics(find.text('Pinned · 1')),
        isSemantics(
          label: 'Pinned, 1 note',
          isButton: true,
          isExpanded: true,
          hasExpandedState: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('searching drops the headings', (WidgetTester tester) async {
      await _pumpNotes(
        tester,
        notes: <NoteModel>[
          _note(1, 'Pinned note', pinned: true),
          _note(2, 'Other note'),
        ],
      );

      await tester.enterText(find.byType(TextField).first, 'Other');
      await tester.pumpAndSettle();

      expect(find.byType(VWSectionDisclosure), findsNothing);
      expect(find.text('Other note'), findsOneWidget);
      expect(find.text('Pinned note'), findsNothing);
    });
  });
}
