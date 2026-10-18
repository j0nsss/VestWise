import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:vestwise/app.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/core/database/isar_service.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/core/theme/theme_provider.dart';
import 'package:vestwise/core/theme/theme_store.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database before the first frame so screens never show a spinner
  // for it (P1-T2). `openIsar` is idempotent.
  final Isar isar = await openIsar();

  // Seed the default finance categories on first launch (P3-FIN-1). The
  // repository call is a no-op once categories exist.
  await FinanceRepositoryImpl(isar).seedDefaultCategories();

  // Prepare notifications up front; permission is requested later, at a
  // sensible moment (P4-T2).
  final NotificationService notificationService = NotificationService();
  await notificationService.init();

  // Read the persisted theme choice before the first frame, so launch never
  // flashes the wrong theme (P5-T4).
  final ThemeMode themeMode = await ThemeStore.load();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(AsyncValue<Isar>.data(isar)),
        notificationServiceProvider.overrideWithValue(notificationService),
        themeModeProvider.overrideWith(
          () => ThemeModeNotifier(themeMode),
        ),
      ],
      child: const VestWiseApp(),
    ),
  );
}
