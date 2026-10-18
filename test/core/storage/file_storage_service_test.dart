import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/storage/file_storage_service.dart';

void main() {
  late Directory base;
  late FileStorageService service;

  setUp(() async {
    base = await Directory.systemTemp.createTemp('vestwise_files');
    service = FileStorageService(baseDirectory: base);
  });

  tearDown(() async {
    if (await base.exists()) {
      await base.delete(recursive: true);
    }
  });

  test('getImportedFilesDir creates the folder on demand', () async {
    final Directory dir = await service.getImportedFilesDir();
    expect(dir.path, contains(FileStorageService.importedDirName));
    expect(await dir.exists(), isTrue);
  });

  test(
    'copyFileIntoImportedStorage copies and leaves the original untouched',
    () async {
      final File source = File('${base.path}/doc.txt')
        ..writeAsStringSync('hello vestwise');

      final File copied = await service.copyFileIntoImportedStorage(source);

      expect(copied.path, contains(FileStorageService.importedDirName));
      expect(await copied.exists(), isTrue);
      expect(await copied.readAsString(), 'hello vestwise');
      expect(await source.exists(), isTrue);
      expect(await source.readAsString(), 'hello vestwise');
    },
  );

  test(
    'deleteLocalFile removes the stored file via its relative path',
    () async {
      final File copied = await service.saveBytesIntoImportedStorage(
        'note.txt',
        <int>[1, 2, 3],
      );
      final String relative = service.relativePathOf(copied);
      expect(await copied.exists(), isTrue);

      await service.deleteLocalFile(relative);

      expect(await copied.exists(), isFalse);
    },
  );

  test('getImportedFilesSizeBytes sums stored file sizes', () async {
    await service.saveBytesIntoImportedStorage(
      'a.bin',
      List<int>.filled(10, 0),
    );
    await service.saveBytesIntoImportedStorage('b.bin', List<int>.filled(5, 0));

    expect(await service.getImportedFilesSizeBytes(), 15);
  });
}
