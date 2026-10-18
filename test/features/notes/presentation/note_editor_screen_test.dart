import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/domain/repositories/notes_repository.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:vestwise/features/notes/presentation/widgets/document_title_field.dart';
import 'package:vestwise/features/notes/presentation/widgets/last_edited_label.dart';

class _FakeNotesRepository implements NotesRepository {
  _FakeNotesRepository({this.note});

  NoteModel? note;
  NoteModel? updated;
  NoteModel? created;

  @override
  Future<Result<NoteModel>> getNoteById(int id) async =>
      note == null ? const Error<NoteModel>(UnexpectedFailure('missing')) : Success<NoteModel>(note!);

  @override
  Future<Result<void>> updateNote(NoteModel note) async {
    updated = note;
    return const Success<void>(null);
  }

  @override
  Future<Result<int>> createNote(NoteModel note) async {
    created = note;
    return const Success<int>(7);
  }

  @override
  Future<Result<void>> deleteNote(int id) async => const Success<void>(null);

  @override
  Stream<List<NoteModel>> watchAllNotes() => Stream.value(const <NoteModel>[]);

  @override
  Stream<List<NoteModel>> watchNotesMatching(String query) =>
      Stream.value(const <NoteModel>[]);

  @override
  Stream<List<ImportedDocumentModel>> watchImportedDocuments() =>
      Stream.value(const <ImportedDocumentModel>[]);

  @override
  Future<Result<ImportedDocumentModel>> getDocumentById(int id) async =>
      const Error<ImportedDocumentModel>(UnexpectedFailure('missing'));

  @override
  Future<Result<int>> createImportedDocument(ImportedDocumentModel d) async =>
      const Success<int>(1);

  @override
  Future<Result<void>> deleteImportedDocument(int id) async =>
      const Success<void>(null);
}

Future<_FakeNotesRepository> _pumpEditor(
  WidgetTester tester, {
  required String noteId,
  NoteModel? note,
}) async {
  final _FakeNotesRepository repository = _FakeNotesRepository(note: note);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notesRepositoryProvider.overrideWith((Ref ref) => repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        // Same delegate the app adds (lib/app.dart): the Quill toolbar reads
        // its tooltips from these localizations.
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          FlutterQuillLocalizations.delegate,
        ],
        home: NoteEditorScreen(noteId: noteId),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return repository;
}

void main() {
  group('NoteEditorScreen document header (P10-NOTES-1)', () {
    testWidgets('an existing note shows its title and when it was edited', (
      WidgetTester tester,
    ) async {
      final DateTime updatedAt = DateTime.now().subtract(
        const Duration(hours: 2),
      );

      await _pumpEditor(
        tester,
        noteId: '3',
        note: NoteModel()
          ..id = 3
          ..title = 'Groceries'
          ..contentJson = '[]'
          ..createdAt = updatedAt
          ..updatedAt = updatedAt,
      );

      expect(find.byType(DocumentTitleField), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Edited 2h ago'), findsOneWidget);
      // The bar no longer repeats the screen name.
      expect(find.text('Edit note'), findsNothing);
      expect(find.text('New note'), findsNothing);
    });

    testWidgets('a new note has no last-edited line until it is saved', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester, noteId: 'new');

      expect(find.byType(DocumentTitleField), findsOneWidget);
      expect(find.byType(LastEditedLabel), findsNothing);
      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('a title edit autosaves and then reports the fresh edit', (
      WidgetTester tester,
    ) async {
      final DateTime updatedAt = DateTime.now().subtract(
        const Duration(days: 2),
      );
      final _FakeNotesRepository repository = await _pumpEditor(
        tester,
        noteId: '3',
        note: NoteModel()
          ..id = 3
          ..title = 'Old'
          ..contentJson = '[]'
          ..createdAt = updatedAt
          ..updatedAt = updatedAt,
      );

      expect(find.text('Edited 2d ago'), findsOneWidget);

      await tester.enterText(find.byType(DocumentTitleField), 'New title');
      expect(repository.updated, isNull, reason: 'debounced, not immediate');

      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(repository.updated?.title, 'New title');
      expect(find.text('Edited just now'), findsOneWidget);
    });

    testWidgets('an empty note is not written at all', (
      WidgetTester tester,
    ) async {
      final _FakeNotesRepository repository =
          await _pumpEditor(tester, noteId: 'new');

      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(repository.created, isNull);
    });

    testWidgets('the title is marked as a header for screen readers', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pumpEditor(tester, noteId: 'new');

      expect(
        tester.getSemantics(find.byType(DocumentTitleField)),
        isSemantics(isHeader: true, isTextField: true),
      );
      // Disposed inline: a handle still open at the end of the test body is
      // itself a failure.
      handle.dispose();
    });
  });
}
