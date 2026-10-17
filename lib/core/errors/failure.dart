/// Typed failures returned across layer boundaries (plan §1.2, P1-T1).
///
/// Repositories and services never throw across layers; they return a
/// [Result] carrying one of these.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

final class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message);
}

final class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// A failure that does not fit the known categories.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
