import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/router/route_paths.dart';

/// The shared screen header from the Phase 13 mockups: the brand lockup on
/// the left (logo tile + "VESTWISE" overline + screen title), and the
/// settings action on the right, for every tab that does not need more.
///
/// The header is translucent on purpose (screens tint it `surface` at 80% and
/// blur whatever scrolls beneath); this widget only composes the content,
/// never the glass.
class VWScreenHeader extends StatelessWidget {
  const VWScreenHeader({
    required this.title,
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: <Widget>[
            // Brand lockup. The logo is the app's own adaptive-icon artwork.
            ExcludeSemantics(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'VESTWISE',
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium!.copyWith(
                    height: 1.15,
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ...actions,
            _HeaderIconButton(
              tooltip: 'Settings',
              icon: Icons.settings_outlined,
              onPressed: () => context.push(RoutePaths.settings),
            ),
          ],
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
