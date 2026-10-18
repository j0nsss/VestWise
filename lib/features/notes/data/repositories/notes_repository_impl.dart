import 'package:isar_community/isar.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/errors/result_guard.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._isar);

  final Isar _isar;

  IsarCollection<NoteModel> get _notes => _isar.noteModels;
  IsarCollection<ImportedDocumentModel> get _documents =>
      _isar.importedDocumentModels;

  @override
  Stream<List<NoteModel>> watchAllNotes() => _notes
      .where()
      .sortByIsPinnedDesc()
      .thenByUpdatedAtDesc()
      .watch(fireImmediately: true);

  @override
  Stream<List<NoteModel>> watchNotesMatching(String query) {
    final String needle = query.trim();
    if (needle.isEmpty) {
      return watchAllNotes();
    }
    return _notes
        .filter()
        .titleContains(needle, caseSensitive: false)
        .or()
        .contentPlainTextContains(needle, caseSensitive: false)
        .sortByIsPinnedDesc()
        .thenByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ImportedDocumentModel>> watchImportedDocuments() =>
      _documents.where().sortByImportedAtDesc().watch(fireImmediately: true);

  @override
  Future<Result<NoteModel>> getNoteById(int id) => resultGuard(() async {
    final NoteModel? note = await _notes.get(id);
    if (note == null) {
      throw StateError('Note $id not found');
    }
    return note;
  }, operation: 'getNoteById');

  @override
  Future<Result<int>> createNote(NoteModel note) => resultGuard(() async {
    await _isar.writeTxn(() async {
      note.id = await _notes.put(note);
    });
    return note.id;
  }, operation: 'createNote');

  @override
  Future<Result<void>> updateNote(NoteModel note) => resultGuard(() async {
    await _isar.writeTxn(() => _notes.put(note));
  }, operation: 'updateNote');

  @override
  Future<Result<void>> deleteNote(int id) => resultGuard(() async {
    await _isar.writeTxn(() => _notes.delete(id));
  }, operation: 'deleteNote');

  @override
  Future<Result<ImportedDocumentModel>> getDocumentById(int id) =>
      resultGuard(() async {
        final ImportedDocumentModel? document = await _documents.get(id);
        if (document == null) {
          throw StateError('Document $id not found');
        }
        return document;
      }, operation: 'getDocumentById');

  @override
  Future<Result<int>> createImportedDocument(ImportedDocumentModel document) =>
      resultGuard(() async {
        await _isar.writeTxn(() async {
          document.id = await _documents.put(document);
        });
        return document.id;
      }, operation: 'createImportedDocument');

  @override
  Future<Result<void>> deleteImportedDocument(int id) => resultGuard(() async {
    await _isar.writeTxn(() => _documents.delete(id));
  }, operation: 'deleteImportedDocument');
}
