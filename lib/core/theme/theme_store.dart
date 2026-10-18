import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's theme choice (plan P5-T4).
///
/// Deliberately separate from [ThemeModeNotifier] so `main()` can read the
/// stored value *before the first frame* — otherwise the app would briefly
/// render the wrong theme on launch.
abstract final class ThemeStore {
  static const String key = 'vw_theme_mode';

  /// Stored as the enum name (`system`/`light`/`dark`) so the on-disk value is
  /// readable and survives enum reordering.
  static ThemeMode decode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String encode(ThemeMode mode) => mode.name;

  static Future<ThemeMode> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return decode(prefs.getString(key));
  }

  static Future<void> save(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, encode(mode));
  }
}
