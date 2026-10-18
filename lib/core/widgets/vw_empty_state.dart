import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_button.dart';

/// Consistent empty-list/first-run state: icon + message + optional CTA
/// (plan P1-T6). Every feature's empty state uses this.
class VWEmptyState extends StatelessWidget {
  const VWEmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final IconData icon;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;

    return Center(
      // Scrollable so a long message never overflows a short viewport. Centers
      // when there is room and scrolls when there is not, without a
      // LayoutBuilder (which would break parents that query intrinsic
      // dimensions, e.g. `SliverFillRemaining(hasScrollBody: false)`).
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: muted),
            const SizedBox(height: AppSpacing.lg),
            if (title != null) ...<Widget>[
              Text(
                title!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              VWButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
