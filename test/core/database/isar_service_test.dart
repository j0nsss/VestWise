import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:vestwise/core/database/isar_service.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  test('all schemas open, persist across a reopen, and openIsar is idempotent',
      () async {
    final Directory dir = await Directory.systemTemp.createTemp('vestwise_db');

    final Isar first = await Isar.open(isarSchemas, directory: dir.path);
    await first.writeTxn(() async {
      await first.categoryModels.put(
        CategoryModel()
          ..name = 'Food'
          ..iconCodePoint = 0xe56c
          ..colorValue = 0xFF16A34A
          ..type = TransactionType.expense
          ..isDefault = true,
      );
    });

    // openIsar() must return the already-open instance instead of throwing.
    expect(Isar.getInstance(), same(first));
    expect(await openIsar(), same(first));

    await first.close();

    // Reopen from the same directory: data must survive.
    final Isar reopened = await Isar.open(isarSchemas, directory: dir.path);
    final List<CategoryModel> categories =
        await reopened.categoryModels.where().findAll();
    expect(categories, hasLength(1));
    expect(categories.single.name, 'Food');
    expect(categories.single.type, TransactionType.expense);

    await reopened.close();
    await dir.delete(recursive: true);
  });
}
