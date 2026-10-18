import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/storage/file_storage_service.dart';
import 'package:vestwise/core/widgets/vw_animated_list_item.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_empty_state.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';
import 'package:vestwise/features/notes/data/models/imported_document_model.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';
import 'package:vestwise/features/notes/presentation/widgets/document_list_tile.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_list_tile.dart';

/// Notes workspace: a searchable notes list and an imported-documents list,
/// split into two tabs (plan P3-NOTES-1 / P3-NOTES-3).
class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: VWAppBar(
          title: AppStrings.notes,
          actions: <Widget>[
            IconButton(
              icon: _importing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              tooltip: 'Import document',
              onPressed: _importing ? null : _importDocument,
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Notes'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go(RoutePaths.noteEditorFor(RoutePaths.newId)),
          child: const Icon(Icons.add),
        ),
        body: const TabBarView(
          children: <Widget>[_NotesTab(), _DocumentsTab()],
        ),
      ),
    );
  }

  Future<void> _importDocument() async {
    setState(() => _importing = true);
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf', 'docx', 'doc', 'txt'],
      );
      if (files.isEmpty) {
        return;
      }
      final PlatformFile picked = files.first;
      final FileStorageService storage = ref.read(fileStorageServiceProvider);

      // Copy into app-owned storage so the file survives picker-cache cleanup.
      final stored = await storage.copyPickedFileToLocalStorage(picked);
      final String extension =
          picked.extension ?? _extensionOf(picked.name);

      await ref.read(notesRepositoryProvider).createImportedDocument(
            ImportedDocumentModel()
              ..fileName = picked.name
              ..relativeFilePath = storage.relativePathOf(stored)
              ..fileExtension = extension
              ..fileSizeBytes = await stored.length()
              ..importedAt = DateTime.now(),
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  String _extensionOf(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    return dot == -1 ? 'file' : fileName.substring(dot + 1);
  }
}

class _NotesTab extends ConsumerStatefulWidget {
  const _NotesTab();

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<NoteModel>> notesAsync =
        ref.watch(watchNotesMatchingProvider(_query));

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: VWTextField(
            controller: _searchController,
            hint: 'Search notes',
            prefixIcon: const Icon(Icons.search),
            onChanged: (String value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: notesAsync.when(
            loading: () => const VWLoadingIndicator(),
            error: (Object error, StackTrace stack) => const VWEmptyState(
              icon: Icons.error_outline,
              message: 'Could not load your notes.',
            ),
            data: (List<NoteModel> notes) {
              if (notes.isEmpty) {
                return VWEmptyState(
                  icon: Icons.sticky_note_2_outlined,
                  title: _query.isEmpty ? 'No notes yet' : 'No matches',
                  message: _query.isEmpty
                      ? 'Write your first note to get started.'
                      : 'No notes match “$_query”.',
                  actionLabel: _query.isEmpty ? 'New note' : null,
                  onAction: _query.isEmpty
                      ? () => context
                          .go(RoutePaths.noteEditorFor(RoutePaths.newId))
                      : null,
                );
              }
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) {
                  final NoteModel note = notes[index];
                  final Widget tile = NoteListTile(
                    note: note,
                    onTap: () =>
                        context.go(RoutePaths.noteEditorFor(note.id)),
                    onTogglePin: () => _togglePin(note),
                  );
                  final Key key = ValueKey<int>(note.id);
                  return VWAnimatedListItem.animates(index)
                      ? VWAnimatedListItem(key: key, child: tile)
                      : KeyedSubtree(key: key, child: tile);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _togglePin(NoteModel note) async {
    await ref.read(notesRepositoryProvider).updateNote(
          note..isPinned = !note.isPinned,
        );
  }
}

class _DocumentsTab extends ConsumerWidget {
  const _DocumentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ImportedDocumentModel>> documentsAsync =
        ref.watch(watchImportedDocumentsProvider);

    return documentsAsync.when(
      loading: () => const VWLoadingIndicator(),
      error: (Object error, StackTrace stack) => const VWEmptyState(
        icon: Icons.error_outline,
        message: 'Could not load your documents.',
      ),
      data: (List<ImportedDocumentModel> documents) {
        if (documents.isEmpty) {
          return const VWEmptyState(
            icon: Icons.folder_open_outlined,
            title: 'No documents',
            message: 'Import a PDF, DOCX or TXT file to keep it offline.',
          );
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final ImportedDocumentModel document = documents[index];
                  final Widget tile = DocumentListTile(
                    document: document,
                    onTap: () =>
                        context.go(RoutePaths.documentViewerFor(document.id)),
                    onDelete: () => _delete(context, ref, document),
                  );
                  final Key key = ValueKey<int>(document.id);
                  return VWAnimatedListItem.animates(index)
                      ? VWAnimatedListItem(key: key, child: tile)
                      : KeyedSubtree(key: key, child: tile);
                },
              ),
            ),
            const Divider(height: 1),
            _StorageReadout(documentCount: documents.length),
          ],
        );
      },
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ImportedDocumentModel document,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('“${document.fileName}” will be removed from the app.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    // Remove the file from disk first, then the metadata row (P4-T4).
    await ref
        .read(fileStorageServiceProvider)
        .deleteLocalFile(document.relativeFilePath);
    await ref.read(notesRepositoryProvider).deleteImportedDocument(document.id);
    ref.invalidate(importedFilesSizeProvider);
  }
}

/// Footer readout making the offline-local footprint visible (P4-T4).
class _StorageReadout extends ConsumerWidget {
  const _StorageReadout({required this.documentCount});

  final int documentCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<int> sizeAsync = ref.watch(importedFilesSizeProvider);
    final int? bytes = sizeAsync.value;
    final String label = bytes == null ? '…' : formatBytes(bytes);
    final String files = documentCount == 1 ? 'file' : 'files';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.sd_storage_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label used · $documentCount $files',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
