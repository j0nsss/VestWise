import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vestwise/core/theme/theme_provider.dart';
import 'package:vestwise/core/theme/theme_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('ThemeStore', () {
    test('round-trips every ThemeMode', () {
      for (final ThemeMode mode in ThemeMode.values) {
        expect(ThemeStore.decode(ThemeStore.encode(mode)), mode);
      }
    });

    test('defaults to system for an unknown or missing value', () {
      expect(ThemeStore.decode(null), ThemeMode.system);
      expect(ThemeStore.decode('sepia'), ThemeMode.system);
    });

    test('loads what was saved', () async {
      await ThemeStore.save(ThemeMode.dark);

      expect(await ThemeStore.load(), ThemeMode.dark);
    });
  });

  group('ThemeModeNotifier (P5-T4)', () {
    test('starts from the mode read before the first frame', () {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          themeModeProvider.overrideWith(() => ThemeModeNotifier(ThemeMode.dark)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('persists a change so the next launch paints the same theme',
        () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).setThemeMode(
            ThemeMode.light,
          );

      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(await ThemeStore.load(), ThemeMode.light);
    });
  });
}
