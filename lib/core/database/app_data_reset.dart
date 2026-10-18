import 'package:isar_community/isar.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/core/storage/file_storage_service.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';

/// Returns the app to a first-run state: no rows, no imported files, no pending
/// reminders (plan P5-T4). Shared by the Settings "Clear all data" action and
/// its test.
///
/// Deliberately leaves `shared_preferences` alone — the theme choice and the
/// "already asked for notification permission" flags describe facts about the
/// user's OS state, which wiping local data does not change.
Future<void> resetAllData({
  required Isar isar,
  required FileStorageService storage,
  required NotificationService notifications,
}) async {
  // Drop scheduled reminders first, so nothing can fire against deleted data.
  try {
    await notifications.cancelAll();
  } catch (_) {
    // The plugin channel can be unavailable (tests, desktop); the reset still
    // has to succeed.
  }

  await isar.writeTxn(() => isar.clear());

  await storage.deleteAllImportedFiles();

  // Re-seed the default categories so the app is immediately usable again
  // instead of leaving an empty category picker behind (P3-FIN-1).
  await FinanceRepositoryImpl(isar).seedDefaultCategories();
}
