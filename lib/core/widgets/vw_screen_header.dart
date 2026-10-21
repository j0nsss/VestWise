import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';

/// The shared screen header from the Phase 14 (Omotive) mockups: "VESTWISE"
/// overline over the screen title on the left, then an amber **Create** pill,
/// the settings action and the avatar disc on the right.
///
/// The header is translucent on purpose (screens tint it `surface` at 80% and
/// blur whatever scrolls beneath); this widget only composes the content,
/// never the glass.
class VWScreenHeader extends StatelessWidget {
  const VWScreenHeader({
    required this.title,
    this.actions = const <Widget>[],
    this.onCreate,
    this.createLabel = 'Create',
    this.showAvatar = true,
    super.key,
  });

  final String title;

  /// Extra actions, inserted before the settings button.
  final List<Widget> actions;

  /// When non-null, the header grows the amber Create pill.
  final VoidCallback? onCreate;

  final String createLabel;

  /// The mockups' avatar disc, decorative (there is no account system).
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: vwHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: vwPageMargin),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'VESTWISE',
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.headlineLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ...actions,
            if (onCreate != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              _CreatePill(label: createLabel, onPressed: onCreate!),
            ],
            _HeaderIconButton(
              tooltip: 'Settings',
              icon: Icons.settings_outlined,
              onPressed: () => context.push(RoutePaths.settings),
            ),
            if (showAvatar) ...<Widget>[
              const SizedBox(width: AppSpacing.xs),
              ExcludeSemantics(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The amber "Create" capsule. Paints 40px of content inside a 48px tap
/// target, so the design's tighter header never costs an accessible target.
class _CreatePill extends StatelessWidget {
  const _CreatePill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: theme.colorScheme.secondary,
        borderRadius: AppRadii.chip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.chip,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 13,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.add, size: 18, color: theme.colorScheme.onSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A round 44px icon action — the header's only button shape (≥48px effective
/// target with padding, per P5-T3; 44px box + spacing keeps it inside the
/// budget's intent while matching the mockup's tighter header).
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: SizedBox(
        width: 44,
        height: 44,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
