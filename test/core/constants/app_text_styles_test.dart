import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/constants/app_text_styles.dart';
import 'package:vestwise/core/theme/app_theme.dart';

/// The type scale must be complete (plan2.md P8-T3).
///
/// `app_theme.dart` installs `AppTextStyles.textTheme` with `textTheme:`, which
/// replaces the Material default scale instead of merging with it. A role that
/// is not defined here therefore resolves to `null` and its text silently falls
/// back to `DefaultTextStyle` — a real bug this test now prevents.
void main() {
  Map<String, TextStyle?> roles(TextTheme t) => <String, TextStyle?>{
    'displayLarge': t.displayLarge,
    'displayMedium': t.displayMedium,
    'displaySmall': t.displaySmall,
    'headlineMedium': t.headlineMedium,
    'headlineSmall': t.headlineSmall,
    'titleLarge': t.titleLarge,
    'titleMedium': t.titleMedium,
    'titleSmall': t.titleSmall,
    'bodyLarge': t.bodyLarge,
    'bodyMedium': t.bodyMedium,
    'bodySmall': t.bodySmall,
    'labelLarge': t.labelLarge,
    'labelMedium': t.labelMedium,
    'labelSmall': t.labelSmall,
  };

  test('every role the app can ask for is defined', () {
    for (final MapEntry<String, TextStyle?> role in roles(
      AppTextStyles.textTheme,
    ).entries) {
      expect(role.value, isNotNull, reason: '${role.key} is undefined');
      expect(
        role.value!.fontSize,
        isNotNull,
        reason: '${role.key} has no size',
      );
      expect(
        role.value!.fontWeight,
        isNotNull,
        reason: '${role.key} has no weight',
      );
    }
  });

  test('the roles the app already uses resolve through the theme', () {
    // These are the ones that were null before this task: titleSmall (8 call
    // sites), bodySmall (6), headlineMedium (3), labelMedium, labelLarge,
    // headlineSmall, bodyLarge.
    for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      for (final String name in <String>[
        'titleSmall',
        'bodySmall',
        'headlineMedium',
        'headlineSmall',
        'bodyLarge',
        'labelMedium',
        'labelLarge',
      ]) {
        expect(
          roles(theme.textTheme)[name],
          isNotNull,
          reason: '$name is null on the ${theme.brightness.name} theme',
        );
      }
    }
  });

  test('weight contrast carries the hierarchy', () {
    const TextTheme t = AppTextStyles.textTheme;

    expect(t.titleMedium!.fontWeight, FontWeight.w600);
    expect(t.titleLarge!.fontWeight, FontWeight.w700);
    expect(t.bodyMedium!.fontWeight, FontWeight.w400);
    expect(t.labelLarge!.fontWeight, FontWeight.w600);
    expect(t.displaySmall!.fontWeight, FontWeight.w800);
  });

  test('sizes step down in a readable order', () {
    const TextTheme t = AppTextStyles.textTheme;

    // Phase 13's scale follows the design system rather than strict Material
    // ordering: titleLarge carries the mobile headline slot (26), so it sits
    // above headlineMedium (24) and below displaySmall (36).
    expect(t.displaySmall!.fontSize, greaterThan(t.titleLarge!.fontSize!));
    expect(t.titleLarge!.fontSize, greaterThan(t.headlineMedium!.fontSize!));
    expect(t.headlineMedium!.fontSize, greaterThan(t.titleMedium!.fontSize!));
    expect(t.titleMedium!.fontSize, greaterThan(t.titleSmall!.fontSize!));
    expect(t.bodyLarge!.fontSize, greaterThan(t.bodyMedium!.fontSize!));
    expect(t.bodyMedium!.fontSize, greaterThan(t.bodySmall!.fontSize!));
    expect(t.labelLarge!.fontSize, greaterThan(t.labelMedium!.fontSize!));
  });

  test('the theme keeps the Plus Jakarta Sans family', () {
    expect(
      AppTheme.light.textTheme.bodyMedium!.fontFamily,
      'PlusJakartaSans',
    );
    expect(
      AppTheme.dark.textTheme.bodyMedium!.fontFamily,
      'PlusJakartaSans',
    );
  });
}
