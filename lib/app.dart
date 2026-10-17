import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestwise/core/constants/app_strings.dart';
import 'package:vestwise/core/router/app_router.dart';
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
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
