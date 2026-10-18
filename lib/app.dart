import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
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
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en')],
    );
  }
}
