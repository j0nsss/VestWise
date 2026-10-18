import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_inline_spinner.dart';

/// Centered spinner for screen-level async states (plan P1-T6/P5-T2). The only
/// sanctioned full-screen loading indicator — never drop a bare
/// [CircularProgressIndicator] into a screen.
class VWLoadingIndicator extends StatelessWidget {
  const VWLoadingIndicator({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const VWInlineSpinner(dimension: 36),
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
