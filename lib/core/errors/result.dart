import 'package:vestwise/core/errors/failure.dart';

/// A success/failure wrapper used as the return type of repository and service
/// methods (plan §1.2, P1-T1). Avoids throwing across layer boundaries so the
/// UI can always render a graceful state.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isError => this is Error<T>;

  /// The success value, or `null` when this is an [Error].
  T? get dataOrNull => switch (this) {
    Success<T>(:final T data) => data,
    Error<T>() => null,
  };

  /// The failure, or `null` when this is a [Success].
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(:final Failure failure) => failure,
  };

  /// Collapses both variants into a single value.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) => switch (this) {
    Success<T>(:final T data) => onSuccess(data),
    Error<T>(:final Failure failure) => onError(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}
