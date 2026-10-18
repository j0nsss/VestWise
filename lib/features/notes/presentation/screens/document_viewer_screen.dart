import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/storage/file_storage_service.dart';
import 'package:vestwise/core/utils/byte_format.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';

/// In-app document viewer (plan P3-NOTES-4).
///
/// PDFs render natively via `flutter_pdfview`. Formats without a reliable
/// offline Flutter renderer (DOCX/DOC/TXT) show a metadata card with an
/// "Open externally" action instead of attempting a fragile render.
class DocumentViewerScreen extends ConsumerStatefulWidget {
  const DocumentViewerScreen({required this.documentId, super.key});

  final String? documentId;

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  ImportedDocumentModel? _document;
  String? _absolutePath;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final int? id = int.tryParse(widget.documentId ?? '');
    if (id == null) {
      setState(() {
        _loading = false;
        _error = 'Document not found.';
      });
      return;
    }

    final ImportedDocumentModel? document =
        (await ref.read(notesRepositoryProvider).getDocumentById(id)).dataOrNull;
    if (document == null) {
      setState(() {
        _loading = false;
        _error = 'Document not found.';
      });
      return;
    }

    final Directory dir = await ref.read(fileStorageServiceProvider).getImportedFilesDir();
    if (!mounted) {
      return;
    }
    setState(() {
      _document = document;
      _absolutePath = '${dir.path}/${document.relativeFilePath}';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ImportedDocumentModel? document = _document;

    return Scaffold(
      appBar: VWAppBar(title: document?.fileName ?? 'Document'),
      body: _loading
          ? const VWLoadingIndicator()
          : _error != null
              ? VWEmptyState(
                  icon: Icons.error_outline,
                  message: _error!,
                )
              : document!.fileExtension.toLowerCase() == 'pdf'
                  ? _buildPdf(document)
                  : _buildMetadataCard(document),
    );
  }

  Widget _buildPdf(ImportedDocumentModel document) {
    return PDFView(
      filePath: _absolutePath,
      onError: (dynamic error) {
        if (mounted) {
          setState(() => _error = 'Could not render this PDF: $error');
        }
      },
    );
  }

  Widget _buildMetadataCard(ImportedDocumentModel document) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        VWCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.insert_drive_file,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      document.fileName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetaRow(label: 'Type', value: document.fileExtension.toUpperCase()),
              _MetaRow(
                label: 'Size',
                value: formatBytes(document.fileSizeBytes),
              ),
              _MetaRow(
                label: 'Imported',
                value: _formatDate(document.importedAt),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Preview not available in-app — open it in an external app.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              VWButton(
                label: 'Open externally',
                icon: Icons.open_in_new,
                expand: true,
                onPressed: _openExternally,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openExternally() async {
    final String? path = _absolutePath;
    if (path == null) {
      return;
    }
    final OpenResult result = await OpenFilex.open(path);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
