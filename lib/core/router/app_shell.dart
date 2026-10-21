import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/widgets/vw_omotive.dart';

/// The key on the shell's branch-settle fade (P9-T3), so a test can target it
/// instead of guessing among every other `FadeTransition` in the app.
@visibleForTesting
const Key appShellSettleKey = Key('app-shell-settle');

/// Key on the floating dock, so tests and integration runners switch tabs by
/// key instead of by Material internals.
@visibleForTesting
const Key appShellDockKey = Key('app-shell-dock');

/// Persistent bottom-navigation shell hosting the five top-level destinations
/// (plan P1-T5, restyled Phase 14 "Omotive Style"). Each branch keeps its own
/// navigation stack.
///
/// Phase 13 replaced the pinned Material bar with the design's *floating dock*:
/// a detached, pill-shaped glass panel hanging 16px above the bottom edge, so
/// content scrolls beneath it and short pages keep their bottom margin.
/// Phase 14 makes it the Omotive dock: icon-only slots, the active destination
/// carried by an amber filled circle (the labels survive as semantics only).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<VWDockItemSpec> items = <VWDockItemSpec>[
    VWDockItemSpec(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
    VWDockItemSpec(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
    ),
    VWDockItemSpec(
      icon: Icons.sticky_note_2_outlined,
      activeIcon: Icons.sticky_note_2,
    ),
    VWDockItemSpec(
      icon: Icons.check_circle_outline,
      activeIcon: Icons.check_circle,
    ),
    VWDockItemSpec(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Branch switches do not run a page transition (all five live in an
      // IndexedStack), which used to make tab changes land as a hard cut
      // (plan2.md P9-T3). A short opacity settle is the cheapest honest fix: it
      // is a fade of the *same* subtree, so no branch loses its state and no
      // navigation stack is rebuilt.
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _BranchSettle(
              index: navigationShell.currentIndex,
              child: navigationShell,
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 384),
                child: VWDock(
                  key: appShellDockKey,
                  selectedIndex: navigationShell.currentIndex,
                  items: items,
                  labels: const <String>[
                    'Home',
                    AppStrings.finance,
                    AppStrings.notes,
                    AppStrings.tasks,
                    AppStrings.calendar,
                  ],
                  onSelected: _onDestinationSelected,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(int index) {
    // Tapping the active tab pops back to its initial location.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// One dock destination's icon pair.
class VWDockItemSpec {
  const VWDockItemSpec({required this.icon, required this.activeIcon});

  final IconData icon;
  final IconData activeIcon;
}

/// The floating glass dock, Omotive style: icon-only 48px slots inside a
/// 64px capsule, the active one carried by an amber filled circle.
class VWDock extends StatelessWidget {
  const VWDock({
    required this.selectedIndex,
    required this.items,
    required this.labels,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final List<VWDockItemSpec> items;

  /// Kept for semantics only — the Omotive dock paints no labels.
  final List<String> labels;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return VWGlass(
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              _DockItem(index: i, dock: this),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({required this.index, required this.dock});

  final int index;
  final VWDock dock;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool selected = index == dock.selectedIndex;
    final VWDockItemSpec spec = dock.items[index];

    return Semantics(
      button: true,
      selected: selected,
      label: dock.labels[index],
      child: InkWell(
        onTap: () => dock.onSelected(index),
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? scheme.secondary : Colors.transparent,
          ),
          child: AnimatedSwitcher(
            duration: motionDuration(context, AppMotion.stateChange),
            child: Icon(
              selected ? spec.activeIcon : spec.icon,
              key: ValueKey<bool>(selected),
              size: 22,
              color: selected ? scheme.onSecondary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades the shell body from 92% to 100% opacity when [index] changes.
///
/// Not a cross-fade: the outgoing and incoming branches are the same widget in
/// the same element, so swapping them through an `AnimatedSwitcher` would throw
/// away the very state `StatefulShellRoute` exists to preserve. Dimming and
/// restoring the shared subtree gives the switch a landing without that cost,
/// and drops out entirely under reduced motion.
class _BranchSettle extends StatefulWidget {
  const _BranchSettle({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_BranchSettle> createState() => _BranchSettleState();
}

class _BranchSettleState extends State<_BranchSettle>
    with SingleTickerProviderStateMixin {
  /// How far to dip. Subtle on purpose — this is a settle, not a blink.
  static const double _floor = 0.92;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.stateChange,
    value: 1,
  );
  late final Animation<double> _opacity = Tween<double>(begin: _floor, end: 1)
      .animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.standardCurve),
      );

  @override
  void didUpdateWidget(covariant _BranchSettle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return widget.child;
    }

    return FadeTransition(
      key: appShellSettleKey,
      opacity: _opacity,
      child: widget.child,
    );
  }
}
