import 'package:flutter/material.dart';
import 'package:vestwise/core/widgets/vw_section_disclosure.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';

/// The two groups the notes list is split into (plan P10-NOTES-3).
enum NotesSection { pinned, others }

/// One row of the notes list: either a group heading or a note.
///
/// The list is flattened to a row script so it can stay a `ListView.builder`
/// (plan P5-T5: long lists are lazy) instead of nesting a list per section.
sealed class NotesRow {
  const NotesRow();
}

class SectionRow extends NotesRow {
  const SectionRow(this.section, this.count);

  final NotesSection section;
  final int count;
}

class NoteRow extends NotesRow {
  const NoteRow(this.note);

  final NoteModel note;
}

/// Lays [notes] out as rows, honouring [collapsed].
///
/// Group headings appear only when there is something to separate: a library of
/// unpinned notes is a single flat list, not an "Others" heading over
/// everything. While searching ([searching]), matches are shown flat — the
/// point of a search result list is the matches, not their filing.
List<NotesRow> buildNoteRows(
  List<NoteModel> notes, {
  required Set<NotesSection> collapsed,
  bool searching = false,
}) {
  if (searching) {
    return <NotesRow>[for (final NoteModel note in notes) NoteRow(note)];
  }

  final List<NoteModel> pinned =
      notes.where((NoteModel note) => note.isPinned).toList();
  final List<NoteModel> others =
      notes.where((NoteModel note) => !note.isPinned).toList();

  final List<NotesRow> rows = <NotesRow>[];
  // Headings only when both a pinned and an unpinned group exist, so a list
  // that is entirely pinned (or entirely not) reads as one plain list.
  final bool labelled = pinned.isNotEmpty && others.isNotEmpty;

  if (pinned.isNotEmpty) {
    if (labelled) {
      rows.add(SectionRow(NotesSection.pinned, pinned.length));
    }
    if (!collapsed.contains(NotesSection.pinned)) {
      rows.addAll(<NotesRow>[for (final NoteModel note in pinned) NoteRow(note)]);
    }
  }

  if (others.isNotEmpty) {
    if (labelled) {
      rows.add(SectionRow(NotesSection.others, others.length));
    }
    if (!collapsed.contains(NotesSection.others)) {
      rows.addAll(<NotesRow>[for (final NoteModel note in others) NoteRow(note)]);
    }
  }

  return rows;
}

/// Collapsible heading for a group of notes. The chrome lives in
/// [VWSectionDisclosure] (shared with the task list, P10-TASKS-1); this only
/// maps the enum to a name.
class NotesSectionHeader extends StatelessWidget {
  const NotesSectionHeader({
    required this.section,
    required this.count,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  final NotesSection section;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  String get label => switch (section) {
        NotesSection.pinned => 'Pinned',
        NotesSection.others => 'Others',
      };

  @override
  Widget build(BuildContext context) {
    return VWSectionDisclosure(
      label: label,
      count: count,
      unit: 'note',
      expanded: expanded,
      onToggle: onToggle,
    );
  }
}
