import 'package:isar_community/isar.dart';

part 'imported_document_model.g.dart';

@collection
class ImportedDocumentModel {
  Id id = Isar.autoIncrement;

  late String fileName;

  /// Path relative to the app's imported_documents/ directory —
  /// never store an absolute path, since it can change across installs/OS updates.
  late String relativeFilePath;

  /// e.g. "pdf", "docx", "txt"
  late String fileExtension;

  late int fileSizeBytes;

  @Index()
  late DateTime importedAt;

  /// Optional link back to a NoteModel.id if this document was attached
  /// to a specific note rather than imported standalone.
  int? linkedNoteId;
}
