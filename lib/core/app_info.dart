import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App version and build number, e.g. `1.0.0+1` (P5-T4). Degrades to
/// `Unavailable` rather than throwing if the platform metadata is missing.
final FutureProvider<String> appVersionProvider = FutureProvider<String>(
  (Ref ref) async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return 'Unavailable';
    }
  },
);
