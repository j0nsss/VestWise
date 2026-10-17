import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/notes/domain/repositories/notes_repository.dart';
import 'package:vestwise/features/notes/presentation/providers/notes_providers.dart';

/// Rich-text note editor backed by flutter_quill (plan P3-NOTES-2).
///
/// Autosave strategy: a 800ms debounce after the last edit (the plan's preferred
/// option for a notes app), plus a final flush when the app is backgrounded or
/// the screen is closed.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({required this.noteId, super.key});

  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen>
    with WidgetsBindingObserver {
  static const Duration _debounceDelay = Duration(milliseconds: 800);

  final TextEditingController _titleController = TextEditingController();
  final QuillController _quillController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  late final NotesRepository _repository;
  Timer? _debounce;
  int? _noteId;
  bool _loading = true;

  bool get _isEditing => _noteId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repository = ref.read(notesRepositoryProvider);
    _quillController.addListener(_scheduleSave);
    _init();
  }

  Future<void> _init() async {
    final String? raw = widget.noteId;
    final int? id = raw == null ? null : int.tryParse(raw);
    if (id == null || raw == RoutePaths.newId) {
      setState(() => _loading = false);
      return;
    }

    final NoteModel? note = (await _repository.getNoteById(id)).dataOrNull;
    if (note != null) {
      _noteId = note.id;
      _titleController.text = note.title == 'Untitled' ? '' : note.title;
      _quillController.document = _documentFromJson(note.contentJson);
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Document _documentFromJson(String contentJson) {
    try {
      final dynamic decoded = jsonDecode(contentJson);
      if (decoded is List) {
        return Document.fromJson(decoded);
      }
    } catch (_) {
      // Fall through to an empty document for malformed content.
    }
    return Document();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_save());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    unawaited(_save());
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => unawaited(_save()));
  }

  Future<void> _save() async {
    final String title = _titleController.text.trim();
    final String plainText = _quillController.document.toPlainText().trim();
    if (title.isEmpty && plainText.isEmpty) {
      return;
    }

    final String contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    final DateTime now = DateTime.now();

    if (_noteId == null) {
      final NoteModel note = NoteModel()
        ..title = title.isEmpty ? 'Untitled' : title
        ..contentJson = contentJson
        ..contentPlainText = plainText
        ..createdAt = now
        ..updatedAt = now;
      final int? id = (await _repository.createNote(note)).dataOrNull;
      if (id != null) {
        _noteId = id;
      }
    } else {
      final NoteModel? existing =
          (await _repository.getNoteById(_noteId!)).dataOrNull;
      if (existing != null) {
        existing
          ..title = title.isEmpty ? 'Untitled' : title
          ..contentJson = contentJson
          ..contentPlainText = plainText
          ..updatedAt = now;
        await _repository.updateNote(existing);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be permanently removed.'),
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
    if (confirmed != true || !mounted) {
      return;
    }
    _debounce?.cancel();
    _noteId = null; // Prevent the dispose flush from re-creating the note.
    await _repository.deleteNote(int.parse(widget.noteId!));
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWAppBar(
        title: _isEditing ? 'Edit note' : 'New note',
        actions: <Widget>[
          if (_isEditing && widget.noteId != RoutePaths.newId)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _loading
          ? const VWLoadingIndicator()
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: VWTextField(
                    controller: _titleController,
                    label: 'Title',
                    onChanged: (String _) => _scheduleSave(),
                  ),
                ),
                QuillSimpleToolbar(
                  controller: _quillController,
                  config: const QuillSimpleToolbarConfig(),
                ),
                const Divider(height: 1),
                Expanded(
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: const QuillEditorConfig(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      placeholder: 'Start writing…',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
