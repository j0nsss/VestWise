import 'package:flutter/material.dart';

/// Placeholder. Full form lands in Phase 3 (P3-TASK-2).
/// `:id == 'new'` means the create flow.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String? taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(taskId == 'new' ? 'New task' : 'Task')),
      body: Center(child: Text('Task detail ($taskId)')),
    );
  }
}
