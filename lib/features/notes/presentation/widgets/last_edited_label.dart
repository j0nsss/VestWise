import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// How long ago a note was last written, in the compact form a document
/// header uses ("just now", "12m ago", "3h ago", "2d ago", then a plain date).
///
/// Pure so it can be tested without pumping a widget. A negative difference
/// (a clock that moved backwards, or a note saved in the future) reads as
/// "just now" rather than as a nonsensical negative age.
String lastEditedLabel(DateTime updatedAt, {required DateTime now}) {
  final Duration elapsed = now.difference(updatedAt);

  if (elapsed.inMinutes < 1) {
    return 'just now';
  }
  if (elapsed.inHours < 1) {
    return '${elapsed.inMinutes}m ago';
  }
  if (elapsed.inHours < 24) {
    return '${elapsed.inHours}h ago';
  }
  if (elapsed.inDays < 7) {
    return '${elapsed.inDays}d ago';
  }
  return DateFormat.yMMMd().format(updatedAt);
}

/// Muted "last edited" line under a note's title (plan P10-NOTES-1).
class LastEditedLabel extends StatelessWidget {
  const LastEditedLabel({required this.updatedAt, super.key});

  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      'Edited ${lastEditedLabel(updatedAt, now: DateTime.now())}',
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
