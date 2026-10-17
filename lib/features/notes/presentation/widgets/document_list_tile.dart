import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';

/// One row in the imported-documents list (plan P3-NOTES-1): file-type icon,
/// name, size and import date.
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
    final Color muted = theme.colorScheme.onSurfaceVariant;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(_iconFor(document.fileExtension), color: muted),
      ),
      title: Text(document.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${formatBytes(document.fileSizeBytes)} · '
        '${DateFormat.yMMMd().format(document.importedAt)}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete document',
        onPressed: onDelete,
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

/// Human-readable file size, e.g. `1.4 MB`.
String formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  final double kb = bytes / 1024;
  if (kb < 1024) {
    return '${kb.toStringAsFixed(1)} KB';
  }
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}
