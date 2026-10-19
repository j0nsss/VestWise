import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/utils/byte_format.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';

/// One row in the imported-documents list (plan P3-NOTES-1), restyled as a
/// Phase 13 card: file-type badge, name, size + import date, delete action.
class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    required this.document,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final ImportedDocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color muted = scheme.onSurfaceVariant;

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
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.surfaceContainerHighest,
                  child: Icon(_iconFor(document.fileExtension), color: muted),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        document.fileName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${formatBytes(document.fileSizeBytes)} · '
                        '${DateFormat.yMMMd().format(document.importedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete document',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}
