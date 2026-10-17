import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';

/// Data-access boundary for notes and imported documents (plan P2-T2).
abstract interface class NotesRepository {
  Stream<List<NoteModel>> watchAllNotes();

  /// Case-insensitive substring match over title and plain-text content.
  Stream<List<NoteModel>> watchNotesMatching(String query);

  Stream<List<ImportedDocumentModel>> watchImportedDocuments();

  Future<Result<NoteModel>> getNoteById(int id);

  Future<Result<int>> createNote(NoteModel note);

  Future<Result<void>> updateNote(NoteModel note);

  Future<Result<void>> deleteNote(int id);

  Future<Result<ImportedDocumentModel>> getDocumentById(int id);

  Future<Result<int>> createImportedDocument(ImportedDocumentModel document);

  Future<Result<void>> deleteImportedDocument(int id);
}
