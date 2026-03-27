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
        validator: (_) => InputValidationResult.error('invalid'),
        onSubmit: _noopOnSubmitStringInt,
      );
      final observer = DataTestObserver(validated);

      validated.input = 'x';
      expect(validated.hasFailure, isTrue);
      expect(validated.failure.message, 'invalid');
      expect(observer.timesUpdated, 1);
    });

    test('validator clears failure when input becomes valid after invalid', () {
      final validated = InputData<String, int>(
        validator: (s) => s == 'bad' ? InputValidationResult.error('no') : InputValidationResult.valid(),
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
    late InputData<String, int> submitting;

    setUp(() {
      submitting = InputData<String, int>(
        validator: (input) {
          if (int.tryParse(input) != null) {
            return InputValidationResult.valid();
          } else {
            return InputValidationResult.error('Entered number is not valid');
          }
        },
        onSubmit: _parseStringToIntOnSubmit,
      );
    });

    test('parses input into value when valid', () async {
      submitting.input = '42';
      await submitting.submit();
      expect(submitting.valueOrNull, 42);
      expect(submitting.hasFailure, isFalse);
    });

    test('sets failure when input does not parse after validation runs on submit', () async {
      submitting.input = 'not-a-number';
      await submitting.submit();
      expect(submitting.hasFailure, isTrue);
      expect(submitting.hasNoValue, isTrue);
      // Validator runs in submit(); [onSubmit] then sets failure from parse attempt.
      expect(submitting.failure.message, 'Entered data is not valid');
    });

    test('sets failure when submit ends with no value and no failure', () async {
      submitting.input = '42';
      await submitting.submit(
        overrideOnSubmit: (_) async {},
      );
      expect(submitting.hasFailure, isTrue);
      expect(submitting.failure.message, '! No value or failure resolved on submit');
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
