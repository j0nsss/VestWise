import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestwise/core/theme/theme_store.dart';

/// Owns the app's [ThemeMode].
///
/// `main()` reads the persisted choice and seeds the notifier with it via
/// `themeModeProvider.overrideWith`, so the very first frame already uses the
/// right theme (P5-T4). Every change is written back to [ThemeStore].
final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  ThemeModeNotifier([this._initial = ThemeMode.system]);

  final ThemeMode _initial;

  @override
  ThemeMode build() => _initial;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state) {
      return;
    }
    state = mode;
    await ThemeStore.save(mode);
  }

  /// Cycles System → Light → Dark → System. Convenient for a settings toggle.
  Future<void> cycle() => setThemeMode(switch (state) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  });
}
