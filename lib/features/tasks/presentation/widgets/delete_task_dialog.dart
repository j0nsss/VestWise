import 'package:flutter/material.dart';

/// Confirms destroying a task before it happens.
///
/// Shared by the detail screen's delete button and the list's swipe-to-delete
/// (P10-TASKS-3) so the wording and the destructive-action ordering — Cancel
/// listed first, "Delete" second — cannot drift between the two. Returns false
/// when the user cancels *or* dismisses the dialog by tapping outside it;
/// destroying a task is never the default.
Future<bool> confirmTaskDeletion(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Delete task?'),
      content: const Text('This task and its reminder will be removed.'),
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

  return confirmed ?? false;
}
