import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/constants/app_motion.dart';
import 'package:vestwise/core/constants/app_strings.dart';

/// The key on the shell's branch-settle fade (P9-T3), so a test can target it
/// instead of guessing among every other `FadeTransition` in the app.
@visibleForTesting
const Key appShellSettleKey = Key('app-shell-settle');

/// Persistent bottom-navigation shell hosting the five top-level destinations
/// (plan P1-T5). Each branch keeps its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Branch switches do not run a page transition (all five live in an
      // IndexedStack), which used to make tab changes land as a hard cut
      // (plan2.md P9-T3). A short opacity settle is the cheapest honest fix: it
      // is a fade of the *same* subtree, so no branch loses its state and no
      // navigation stack is rebuilt.
      body: _BranchSettle(
        index: navigationShell.currentIndex,
        child: navigationShell,
      ),
      // The bar is flat by theme (P10-NAV-1); this hairline is the only thing
      // separating it from the page, matching how every card is separated.
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle(context)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: AppStrings.dashboard,
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: AppStrings.finance,
            ),
            NavigationDestination(
              icon: Icon(Icons.sticky_note_2_outlined),
              selectedIcon: Icon(Icons.sticky_note_2),
              label: AppStrings.notes,
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
              label: AppStrings.tasks,
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: AppStrings.calendar,
            ),
          ],
        ),
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
