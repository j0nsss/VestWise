import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:vestwise/features/notes/domain/repositories/notes_repository.dart';

part 'notes_providers.g.dart';

@riverpod
NotesRepository notesRepository(Ref ref) {
  return NotesRepositoryImpl(ref.watch(isarProvider).requireValue);
}

@riverpod
Stream<List<NoteModel>> watchAllNotes(Ref ref) =>
    ref.watch(notesRepositoryProvider).watchAllNotes();

@riverpod
Stream<List<NoteModel>> watchNotesMatching(Ref ref, String query) =>
    ref.watch(notesRepositoryProvider).watchNotesMatching(query);

@riverpod
Stream<List<ImportedDocumentModel>> watchImportedDocuments(Ref ref) =>
    ref.watch(notesRepositoryProvider).watchImportedDocuments();
