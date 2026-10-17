import 'package:flutter/material.dart';

/// Placeholder. Full viewer lands in Phase 3 (P3-NOTES-4).
class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({required this.documentId, super.key});

  final String? documentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document')),
      body: Center(child: Text('Document viewer ($documentId)')),
    );
  }
}
