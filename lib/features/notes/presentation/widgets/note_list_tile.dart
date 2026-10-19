import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_icon_picker.dart';

/// One row in the notes list (plan P3-NOTES-1), restyled as a Phase 13 card:
/// surface-container panel with the title, plain-text preview, updated time
/// and the pin affordance.
///
/// The icon stays opt-in — a default icon on every row would be decoration,
/// not information (P10-NOTES-2).
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
    final ColorScheme scheme = theme.colorScheme;
    final Color muted = scheme.onSurfaceVariant;
    final String preview = note.contentPlainText.trim();
    final IconData? leadingIcon = note.iconCodePoint == null
        ? null
        : noteIconFor(note.iconCodePoint);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: AppRadii.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (leadingIcon != null) ...<Widget>[
                  Icon(leadingIcon, color: muted, size: 20),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (preview.isNotEmpty)
                        Text(
                          preview,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        DateFormat.yMMMd().add_Hm().format(note.updatedAt),
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: note.isPinned ? scheme.primary : muted,
                  ),
                  tooltip: note.isPinned ? 'Unpin' : 'Pin',
                  onPressed: onTogglePin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
