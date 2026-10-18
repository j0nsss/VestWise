import 'package:flutter/material.dart';
import 'package:vestwise/core/widgets/icon_data_from_code_point.dart';

/// A note icon a user can choose, with the label screen readers announce.
class NoteIconOption {
  const NoteIconOption(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// The closed set of note icons (plan P10-NOTES-2).
///
/// Small and fixed on purpose: these are what gets persisted as a code point,
/// and a note icon is a glance-cue, not a taxonomy. Each option carries its own
/// label so the picker never relies on the icon alone.
const List<NoteIconOption> noteIconOptions = <NoteIconOption>[
  NoteIconOption(Icons.description_outlined, 'Document'),
  NoteIconOption(Icons.sticky_note_2_outlined, 'Note'),
  NoteIconOption(Icons.lightbulb_outline, 'Idea'),
  NoteIconOption(Icons.checklist_outlined, 'Checklist'),
  NoteIconOption(Icons.shopping_cart_outlined, 'Shopping'),
  NoteIconOption(Icons.menu_book_outlined, 'Reading'),
  NoteIconOption(Icons.work_outline, 'Work'),
  NoteIconOption(Icons.favorite_outline, 'Favourite'),
  NoteIconOption(Icons.star_outline, 'Starred'),
  NoteIconOption(Icons.event_outlined, 'Event'),
  NoteIconOption(Icons.travel_explore_outlined, 'Travel'),
  NoteIconOption(Icons.attach_money_outlined, 'Money'),
];

/// The icon for a note, defaulting to a document for notes saved before the
/// field existed (or before the user picked one).
IconData noteIconFor(int? codePoint) => codePoint == null
    ? Icons.description_outlined
    : iconDataFromCodePoint(codePoint);

/// Bottom-sheet grid of [noteIconOptions]. Pops the chosen [IconData], or null
/// when dismissed without choosing.
class NoteIconPicker extends StatelessWidget {
  const NoteIconPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Choose an icon', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: <Widget>[
                for (final NoteIconOption option in noteIconOptions)
                  IconButton(
                    icon: Icon(option.icon),
                    tooltip: option.label,
                    onPressed: () => Navigator.of(context).pop(option.icon),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
