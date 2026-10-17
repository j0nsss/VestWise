import 'package:flutter/material.dart';

/// Placeholder. Full screen lands in Phase 3 (P3-FIN-4).
class FinanceSummaryScreen extends StatelessWidget {
  const FinanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: const Center(child: Text('Finance summary')),
    );
  }
}
