import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';

/// Every Isar collection in VestWise. Keep in sync with `plan.md` §10.
const List<CollectionSchema<dynamic>> isarSchemas = <CollectionSchema<dynamic>>[
  TransactionModelSchema,
  CategoryModelSchema,
  NoteModelSchema,
  ImportedDocumentModelSchema,
  TaskModelSchema,
  CalendarEventModelSchema,
];

/// Opens (or returns the already-open) single Isar instance for the app.
///
/// Idempotent: if an instance is already open, the existing one is returned
/// rather than throwing `Instance has already been opened` (isar.dart:61).
Future<Isar> openIsar() async {
  final Isar? existing = Isar.getInstance();
  if (existing != null) {
    return existing;
  }

  final directory = await getApplicationDocumentsDirectory();
  return Isar.open(isarSchemas, directory: directory.path);
}

/// Closes the open instance. Used by "Clear all data" (P5-T4) and tests.
Future<void> closeIsar() async {
  final Isar? existing = Isar.getInstance();
  if (existing != null) {
    await existing.close();
  }
}
