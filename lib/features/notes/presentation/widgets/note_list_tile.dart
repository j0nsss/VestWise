import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_icon_picker.dart';

/// One row in the notes list: title, plain-text preview, updated time, pin
/// affordance (plan P3-NOTES-1).
class NoteListTile extends StatelessWidget {
  const NoteListTile({
    required this.note,
    this.onTap,
    this.onTogglePin,
    super.key,
  });

  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onTogglePin;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final String preview = note.contentPlainText.trim();

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // Only for notes that have one: a default icon on every row would be
      // decoration, not information (P10-NOTES-2).
      leading: note.iconCodePoint == null
          ? null
          : Icon(noteIconFor(note.iconCodePoint), color: muted),
      title: Text(note.title.isEmpty ? 'Untitled' : note.title, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (preview.isNotEmpty)
            Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(
            DateFormat.yMMMd().add_Hm().format(note.updatedAt),
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: note.isPinned ? theme.colorScheme.primary : muted,
        ),
        tooltip: note.isPinned ? 'Unpin' : 'Pin',
        onPressed: onTogglePin,
      ),
    );
  }
}
