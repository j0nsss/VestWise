import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/database/app_data_reset.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/core/storage/file_storage_service.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:vestwise/features/notes/data/models/note_model.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/data/repositories/tasks_repository_impl.dart';

import '../../helpers/isar_test_harness.dart';

void main() {
  late IsarTestHarness harness;
  late FileStorageService storage;
  late Directory tempDir;

  setUp(() async {
    harness = await IsarTestHarness.create();
    tempDir = await Directory.systemTemp.createTemp('vw_reset_test');
    storage = FileStorageService(baseDirectory: tempDir);
  });

  tearDown(() async {
    await harness.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'clear-all wipes rows, deletes imported files and re-seeds categories',
    () async {
      final FinanceRepositoryImpl finance = FinanceRepositoryImpl(harness.isar);
      await finance.seedDefaultCategories();
      await finance.createTransaction(
        TransactionModel()
          ..amount = 10
          ..type = TransactionType.expense
          ..date = DateTime.now()
          ..createdAt = DateTime.now(),
      );
      await TasksRepositoryImpl(harness.isar).createTask(
        TaskModel()
          ..title = 'Doomed'
          ..priority = TaskPriority.medium
          ..createdAt = DateTime.now(),
      );
      await storage.saveBytesIntoImportedStorage('note.txt', <int>[1, 2, 3]);

      expect(await harness.isar.transactionModels.count(), 1);
      expect(await harness.isar.taskModels.count(), 1);
      expect(await storage.getImportedFilesSizeBytes(), 3);

      // A plain NotificationService is fine here: the plugin channel is absent in
      // tests and `cancelAll` is deliberately best-effort.
      await resetAllData(
        isar: harness.isar,
        storage: storage,
        notifications: NotificationService(),
      );

      expect(await harness.isar.transactionModels.count(), 0);
      expect(await harness.isar.taskModels.count(), 0);
      expect(await harness.isar.noteModels.count(), 0);
      expect(await storage.getImportedFilesSizeBytes(), 0);

      // Default categories come back, so the app is usable immediately.
      expect((await finance.getAllCategories()).dataOrNull, isNotEmpty);
    },
  );
}
