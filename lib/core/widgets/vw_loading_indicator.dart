import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';

/// Centered spinner for async states (plan P1-T6). The only sanctioned loading
/// indicator for screens — never drop a bare [CircularProgressIndicator].
class VWLoadingIndicator extends StatelessWidget {
  const VWLoadingIndicator({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
