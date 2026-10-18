/// Human-readable file size, e.g. `1.4 MB`. Lives in `core/` because both the
/// Notes feature and Settings display it (P4-T4, P5-T4).
String formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  final double kb = bytes / 1024;
  if (kb < 1024) {
    return '${kb.toStringAsFixed(1)} KB';
  }
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}
