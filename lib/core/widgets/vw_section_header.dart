import 'package:flutter/material.dart';

/// Section title with an optional trailing action/text (plan P1-T6). Used by
/// the Dashboard and list screens.
class VWSectionHeader extends StatelessWidget {
  const VWSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget? end = trailing ??
        (actionLabel != null && onAction != null
            ? TextButton(onPressed: onAction, child: Text(actionLabel!))
            : null);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?end,
      ],
    );
  }
}
