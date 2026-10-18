import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:vestwise/core/database/isar_service.dart';

class IsarTestHarness {
  IsarTestHarness(this.isar, this._dir);

  final Isar isar;
  final Directory _dir;

  static bool _coreInitialized = false;

  static Future<IsarTestHarness> create() async {
    if (!_coreInitialized) {
      await Isar.initializeIsarCore(download: true);
      _coreInitialized = true;
    }
    final Directory dir = await Directory.systemTemp.createTemp(
      'vestwise_repo_test',
    );
    final String name = 'test_${DateTime.now().microsecondsSinceEpoch}';
    final Isar isar = await Isar.open(
      isarSchemas,
      directory: dir.path,
      name: name,
    );
    return IsarTestHarness(isar, dir);
  }

  Future<void> dispose() async {
    await isar.close(deleteFromDisk: true);
    if (_dir.existsSync()) {
      await _dir.delete(recursive: true);
    }
  }
}
