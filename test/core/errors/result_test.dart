import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Success reports success and exposes its data', () {
      const Result<int> result = Success<int>(42);

      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('Error reports failure and exposes its failure', () {
      const Failure failure = DatabaseFailure('boom');
      const Result<int> result = Error<int>(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('fold dispatches to the matching branch', () {
      const Result<int> success = Success<int>(1);
      const Result<int> error = Error<int>(ValidationFailure('nope'));

      expect(
        success.fold(onSuccess: (value) => 'ok:$value', onError: (f) => 'err'),
        'ok:1',
      );
      expect(
        error.fold(
          onSuccess: (value) => 'ok:$value',
          onError: (f) => 'err:${f.message}',
        ),
        'err:nope',
      );
    });
  });
}
