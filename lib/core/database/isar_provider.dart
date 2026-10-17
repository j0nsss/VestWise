import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:vestwise/core/database/isar_service.dart';

/// Exposes the app's single [Isar] instance to repositories.
///
/// `main.dart` awaits [openIsar] before `runApp` and overrides this provider
/// with the resolved value, so the first frame never waits on the database.
final FutureProvider<Isar> isarProvider = FutureProvider<Isar>(
  (Ref ref) => openIsar(),
);
