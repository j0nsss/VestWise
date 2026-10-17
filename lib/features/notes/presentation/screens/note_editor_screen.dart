import 'package:flutter/material.dart';

/// Placeholder. Full editor lands in Phase 3 (P3-NOTES-2).
/// `:id == 'new'` means the create flow.
class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({required this.noteId, super.key});

  final String? noteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(noteId == 'new' ? 'New note' : 'Edit note')),
      body: Center(child: Text('Note editor ($noteId)')),
    );
  }
}
