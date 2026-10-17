import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:vestwise/features/notes/domain/repositories/notes_repository.dart';

import '../../../helpers/isar_test_harness.dart';

NoteModel _note({
  String title = 'Groceries',
  String plainText = '',
  bool pinned = false,
}) =>
    NoteModel()
      ..title = title
      ..contentJson = '{}'
      ..contentPlainText = plainText
      ..isPinned = pinned
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

void main() {
  late IsarTestHarness harness;
  late NotesRepository repo;

  setUp(() async {
    harness = await IsarTestHarness.create();
    repo = NotesRepositoryImpl(harness.isar);
  });

  tearDown(() => harness.dispose());

  test('create/get/update/delete a note', () async {
    final int id = (await repo.createNote(_note())).dataOrNull!;
    expect((await repo.getNoteById(id)).dataOrNull?.title, 'Groceries');

    final NoteModel loaded = (await repo.getNoteById(id)).dataOrNull!;
    await repo.updateNote(loaded..title = 'Weekly groceries');
    expect(
      (await repo.getNoteById(id)).dataOrNull?.title,
      'Weekly groceries',
    );

    await repo.deleteNote(id);
    expect(await repo.getNoteById(id), isA<Error<NoteModel>>());
  });

  test('watchNotesMatching finds notes by title or plain-text content', () async {
    await repo.createNote(_note(title: 'Workout plan', plainText: 'legs and back'));
    await repo.createNote(_note(title: 'Reading list', plainText: 'workout science'));

    final List<NoteModel> byTitle =
        await repo.watchNotesMatching('workout').first;
    expect(byTitle, hasLength(2));

    final List<NoteModel> byContent =
        await repo.watchNotesMatching('legs').first;
    expect(byContent.single.title, 'Workout plan');
  });

  test('pinned notes sort first in watchAllNotes', () async {
    await repo.createNote(_note(title: 'Normal'));
    await repo.createNote(_note(title: 'Important', pinned: true));

    final List<NoteModel> notes = await repo.watchAllNotes().first;
    expect(notes.first.title, 'Important');
  });

  test('imported documents can be created, watched and deleted', () async {
    final int id = (await repo.createImportedDocument(
      ImportedDocumentModel()
        ..fileName = 'lease.pdf'
        ..relativeFilePath = 'imported_documents/lease.pdf'
        ..fileExtension = 'pdf'
        ..fileSizeBytes = 2048
        ..importedAt = DateTime.now(),
    ))
        .dataOrNull!;

    final List<ImportedDocumentModel> docs =
        await repo.watchImportedDocuments().first;
    expect(docs.single.fileName, 'lease.pdf');

    await repo.deleteImportedDocument(id);
    expect((await repo.watchImportedDocuments().first), isEmpty);
  });
}
