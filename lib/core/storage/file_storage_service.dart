import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Owns on-disk files for VestWise (plan P1-T3). Only [ImportedDocumentModel]
/// metadata lives in Isar; the bytes live here, under `imported_documents/`.
///
/// The [baseDirectory] override exists for tests, where the `path_provider`
/// plugin is unavailable.
class FileStorageService {
  FileStorageService({this.baseDirectory, Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  static const String importedDirName = 'imported_documents';

  final Directory? baseDirectory;
  final Uuid _uuid;

  Future<Directory> getAppDocumentsDir() async =>
      baseDirectory ?? getApplicationDocumentsDirectory();

  Future<Directory> getImportedFilesDir() async {
    final Directory docs = await getAppDocumentsDir();
    final Directory dir = Directory('${docs.path}/$importedDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies a picked file into app-owned storage as
  /// `imported_documents/<uuid>_<original_name>` and returns the new file.
  ///
  /// Never reference the picker's cache path long-term — the OS may clear it.
  Future<File> copyPickedFileToLocalStorage(PlatformFile pickedFile) async {
    final String? sourcePath = pickedFile.path;
    if (sourcePath != null) {
      return copyFileIntoImportedStorage(File(sourcePath));
    }
    return saveBytesIntoImportedStorage(
      pickedFile.name,
      await pickedFile.readAsBytes(),
    );
  }

  /// Copies a local [source] file into `imported_documents/` and returns the
  /// copy. Kept separate from [copyPickedFileToLocalStorage] so the copy logic
  /// is testable without constructing a picker [PlatformFile].
  Future<File> copyFileIntoImportedStorage(File source) async {
    final Directory dir = await getImportedFilesDir();
    final String targetPath =
        '${dir.path}/${_uniqueNameFor(source.uri.pathSegments.last)}';
    return source.copy(targetPath);
  }

  /// Writes raw [bytes] into `imported_documents/` under [fileName].
  Future<File> saveBytesIntoImportedStorage(
    String fileName,
    List<int> bytes,
  ) async {
    final Directory dir = await getImportedFilesDir();
    final String targetPath = '${dir.path}/${_uniqueNameFor(fileName)}';
    return File(targetPath).writeAsBytes(bytes);
  }

  /// Deletes a file identified by a path relative to `imported_documents/`.
  Future<void> deleteLocalFile(String relativePath) async {
    final Directory dir = await getImportedFilesDir();
    final File file = File('${dir.path}/$relativePath');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Total bytes currently used by imported files (P4-T4 storage readout).
  Future<int> getImportedFilesSizeBytes() async {
    final Directory dir = await getImportedFilesDir();
    int total = 0;
    await for (final FileSystemEntity entity in dir.list()) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// Relative path (to `imported_documents/`) that should be persisted in
  /// [ImportedDocumentModel.relativeFilePath].
  String relativePathOf(File file) {
    final int idx = file.path.lastIndexOf('/$importedDirName/');
    if (idx == -1) {
      return file.uri.pathSegments.last;
    }
    return file.path.substring(idx + importedDirName.length + 2);
  }

  String _uniqueNameFor(String originalName) =>
      '${_uuid.v4()}_${_sanitize(originalName)}';

  String _sanitize(String name) => name.replaceAll(RegExp(r'[^\w.\-]'), '_');
}

final Provider<FileStorageService> fileStorageServiceProvider =
    Provider<FileStorageService>((Ref ref) => FileStorageService());
