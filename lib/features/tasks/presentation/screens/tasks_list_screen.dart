import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_strings.dart';

/// Placeholder. Full screen lands in Phase 3 (P3-TASK-1).
class TasksListScreen extends StatelessWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tasks)),
      body: const Center(child: Text('Tasks')),
    );
  }
}
