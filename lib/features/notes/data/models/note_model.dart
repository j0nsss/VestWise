import 'package:isar_community/isar.dart';

part 'note_model.g.dart';

@collection
class NoteModel {
  Id id = Isar.autoIncrement;

  late String title;

  /// flutter_quill Delta, stored as a JSON string.
  late String contentJson;

  /// Derived plain-text mirror of [contentJson], kept in sync on save,
  /// used for lightweight substring search and list previews.
  String contentPlainText = '';

  List<String> tags = [];

  /// Material icon code point chosen for this note, or null for the default
  /// document icon (plan2.md P10-NOTES-2). Additive and nullable, so notes
  /// written before this field existed load as "no icon" rather than failing.
  int? iconCodePoint;

  bool isPinned = false;

  bool isArchived = false;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;
}
