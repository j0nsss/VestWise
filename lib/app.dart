import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/core/theme/theme_provider.dart';

class VestWiseApp extends ConsumerWidget {
  const VestWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _placeholderRouter,
    );
  }
}

/// Temporary single-route router. Phase 1 (P1-T5) replaces this with
/// `core/router/app_router.dart` exposing a Riverpod `appRouterProvider`
/// backed by the full bottom-navigation shell.
final GoRouter _placeholderRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const _PlaceholderHomeScreen(),
    ),
  ],
);

class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) => const Scaffold();
}
