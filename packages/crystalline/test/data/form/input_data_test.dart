import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../../test_utils/test_logger.dart';

/// Used where [onSubmit] is required but the test does not call [InputData.submit].
Future<void> _noopOnSubmitStringInt(InputData<String, int> data) async {}

Future<void> _noopOnSubmitIntInt(InputData<int, int> data) async {}

/// Parses [String] input to [int] in [onSubmit], mirroring typical form commit behavior.
Future<void> _parseStringToIntOnSubmit(InputData<String, int> data) async {
  final parsedInt = int.tryParse(data.input);
  if (parsedInt != null) {
    data.value = parsedInt;
  } else {
    data.failure = Failure('Entered data is not valid');
  }
}

void main() {
  late InputData<String, int> inputData;
  late DataTestObserver<int, InputData<String, int>> testObserver;

  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    // No validator: most tests assign arbitrary strings and assert notifications;
    // validation is covered in group `validation` and `submit`.
    inputData = InputData<String, int>(
      onSubmit: _noopOnSubmitStringInt,
    );
    testObserver = DataTestObserver(inputData);
  });

  group('input', () {
    test('Should set input', () {
      expect(inputData.hasInput, isFalse);
      inputData.input = 'something';

      expect(inputData.hasInput, isTrue);
      expect(inputData.input, 'something');
      expect(testObserver.timesUpdated, 1);
    });

    test('Should throw InputIsNullException when input getter is used without input', () {
      expect(inputData.inputOrNull, isNull);
      expect(() => inputData.input, throwsA(isA<InputIsNullException>()));
    });

    test('inputOrNull returns the stored value without throwing', () {
      inputData.input = 'stored';
      expect(inputData.inputOrNull, 'stored');
    });

    test('Setting input to null clears hasInput and notifies', () {
      inputData.input = 'first';
      expect(testObserver.timesUpdated, 1);

      inputData.input = null;
      expect(inputData.hasInput, isFalse);
      expect(inputData.inputOrNull, isNull);
      expect(testObserver.timesUpdated, 2);
    });
  });

  group('hint', () {
    test('hint setter stores value and notifies observers', () {
      inputData.hint = 'optional';
      expect(inputData.hint, 'optional');
      expect(testObserver.timesUpdated, 1);
    });
  });

  group('validation', () {
    test('validator sets failure when input is invalid', () {
      final validated = InputData<String, int>(
        validator: (_) => InputValidationResult.error(Failure('invalid')),
        onSubmit: _noopOnSubmitStringInt,
      );
      final observer = DataTestObserver(validated);

      validated.input = 'x';
      expect(validated.hasFailure, isTrue);
      expect(validated.failure.message, 'invalid');
      expect(observer.timesUpdated, 1);
    });

    test(
      'when failure set on validation does not have a FailureType '
      'set failure set on data should have FailureType.hint',
      () {
        final validated = InputData<String, int>(
          validator: (_) => InputValidationResult.error(Failure('invalid')),
          onSubmit: _noopOnSubmitStringInt,
        );
        final observer = DataTestObserver(validated);

        validated.input = 'x';
        expect(validated.hasFailure, isTrue);
        expect(validated.failure.type, FailureType.hint);
        expect(observer.timesUpdated, 1);
      },
    );

    test(
      'when failure set on validation has a FailureType '
      'set failure set on data should not change to FailureType.hint',
      () {
        final validated = InputData<String, int>(
          validator: (_) => InputValidationResult.error(Failure('invalid', type: FailureType.error)),
          onSubmit: _noopOnSubmitStringInt,
        );
        final observer = DataTestObserver(validated);

        validated.input = 'x';
        expect(validated.hasFailure, isTrue);
        expect(validated.failure.type, FailureType.error);
        expect(observer.timesUpdated, 1);
      },
    );

    test('validator clears failure when input becomes valid after invalid', () {
      final validated = InputData<String, int>(
        validator: (s) => s == 'bad' ? InputValidationResult.error(Failure('no')) : InputValidationResult.valid(),
        onSubmit: _noopOnSubmitStringInt,
      );

      validated.input = 'bad';
      expect(validated.hasFailure, isTrue);

      validated.input = 'good';
      expect(validated.hasFailure, isFalse);
    });

    test('without validator, setting input does not clear an existing failure', () {
      final failure = Failure('pre-existing');
      inputData.failure = failure;
      expect(testObserver.timesUpdated, 1);

      inputData.input = 'value';
      expect(inputData.failureOrNull, same(failure));
      expect(testObserver.timesUpdated, 2);
    });
  });

  group('submit', () {
    late InputData<String, int> data;

    setUp(() {
      data = InputData<String, int>(
        validator: (input) {
          if (int.tryParse(input) != null) {
            return InputValidationResult.valid();
          } else {
            return InputValidationResult.error(Failure('Entered number is not valid'));
          }
        },
        onSubmit: _parseStringToIntOnSubmit,
      );
    });

    test('parses input into value when valid', () async {
      data.input = '42';
      await data.submit();
      expect(data.valueOrNull, 42);
      expect(data.hasFailure, isFalse);
    });

    test(
      'If there is a failure set during submit that has no '
      'FailureType then FailureType.error should be set',
      () async {
        data.input = 'nan';
        await data.submit();
        expect(data.hasFailure, isTrue);
        expect(data.failure.type, FailureType.error);
      },
    );

    test(
      'If there is a failure set during submit that has a '
      'FailureType then its type should not change',
      () async {
        data.input = 'nan';
        await data.submit(
          overrideOnSubmit: (input) async {
            final parsedInt = int.tryParse(data.input);
            if (parsedInt != null) {
              data.value = parsedInt;
            } else {
              data.failure = Failure('Entered data is not valid', type: FailureType.hint);
            }
          },
        );
        expect(data.hasFailure, isTrue);
        expect(data.failure.type, isNot(FailureType.error));
      },
    );

    test('sets failure when input does not parse after validation runs on submit', () async {
      data.input = 'not-a-number';
      await data.submit();
      expect(data.hasFailure, isTrue);
      expect(data.hasNoValue, isTrue);
      // Validator runs in submit(); [onSubmit] then sets failure from parse attempt.
      expect(data.failure.message, 'Entered data is not valid');
    });

    test('sets failure when submit ends with no value and no failure', () async {
      data.input = '42';
      await data.submit(
        overrideOnSubmit: (_) async {},
      );
      expect(data.hasFailure, isTrue);
      expect(data.failure.message, '! No value or failure resolved on submit');
      expect(data.failure.type, FailureType.error);
    });
  });

  group('modify', () {
    test('Should batch changes and notify observers only once', () {
      inputData.modify((data) {
        data.input = 'a';
        data.input = 'b';
        data.failure = Failure('err');
      });

      expect(inputData.inputOrNull, 'b');
      expect(testObserver.timesUpdated, 1);
    });
  });

  group('modifyAsync', () {
    test('Should batch async changes and notify observers only once', () async {
      await inputData.modifyAsync((data) async {
        data.input = 'a';
        await Future<void>.value();
        data.input = 'b';
      });

      expect(inputData.inputOrNull, 'b');
      expect(testObserver.timesUpdated, 1);
    });
  });

  group('updateFrom', () {
    test('Should copy state from another InputData of the same type', () {
      final other = InputData<String, int>(
        value: 1,
        input: 'text',
        failure: Failure('f'),
        operation: Operation.create,
        onSubmit: _noopOnSubmitStringInt,
      );

      inputData.updateFrom(other);
      expect(inputData, other);
      expect(testObserver.timesUpdated, 1);
    });

    test('Should throw CannotUpdateFromTypeException for a different InputData type', () {
      final other = InputData<int, int>(
        input: 42,
        onSubmit: _noopOnSubmitIntInt,
      );

      expect(
        () => inputData.updateFrom(other),
        throwsA(isA<CannotUpdateFromTypeException>()),
      );
      expect(testObserver.timesUpdated, 0);
    });
  });

  group('reset', () {
    test('Should clear input and reset base Data fields', () {
      inputData.input = 'x';
      inputData.value = 7;
      inputData.failure = Failure('e');
      inputData.operation = Operation.read;
      inputData.hint = 'hint';

      inputData.reset();

      expect(inputData.hasInput, isFalse);
      expect(inputData.valueOrNull, isNull);
      expect(inputData.failureOrNull, isNull);
      expect(inputData.operationOrNull, isNull);
      expect(inputData.hint, isNull);
    });
  });

  group('copy', () {
    test('copy should equal the source when state matches', () {
      inputData.input = 'copy-me';
      inputData.value = 99;
      inputData.hint = 'hint';
      inputData.failure = Failure('message');

      expect(inputData.copy(), inputData);
    });
  });

  group('constructor', () {
    test('Should accept initial input and report hasInput', () {
      final prefilled = InputData<String, int>(
        input: 'initial',
        onSubmit: _noopOnSubmitStringInt,
      );
      final prefilledObserver = DataTestObserver(prefilled);
      expect(prefilled.hasInput, isTrue);
      expect(prefilled.input, 'initial');
      expect(prefilledObserver.timesUpdated, 0);
    });
  });
}
