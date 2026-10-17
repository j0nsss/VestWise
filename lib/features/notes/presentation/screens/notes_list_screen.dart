import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_strings.dart';

/// Placeholder. Full screen lands in Phase 3 (P3-NOTES-1).
class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notes)),
      body: const Center(child: Text('Notes')),
    );
  }
}
