import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';

/// Runs [action], converting any thrown error into an [Error] carrying a
/// [DatabaseFailure] (plan §1.2 — repositories never throw across layers).
Future<Result<T>> resultGuard<T>(
  Future<T> Function() action, {
  required String operation,
}) async {
  try {
    return Success<T>(await action());
  } catch (error) {
    return Error<T>(DatabaseFailure('$operation failed: $error'));
  }
}
