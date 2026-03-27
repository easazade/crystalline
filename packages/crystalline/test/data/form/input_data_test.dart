import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../../test_utils/test_logger.dart';

void main() {
  late InputData<String, int> inputData;
  late DataTestObserver<int, InputData<String, int>> testObserver;

  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    inputData = InputData();
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
        validator: (_) => InputValidation.error('invalid'),
      );
      final observer = DataTestObserver(validated);

      validated.input = 'x';
      expect(validated.hasFailure, isTrue);
      expect(validated.failure.message, 'invalid');
      expect(observer.timesUpdated, 1);
    });

    test('validator clears failure when input becomes valid after invalid', () {
      final validated = InputData<String, int>(
        validator: (s) => s == 'bad' ? InputValidation.error('no') : InputValidation.valid(),
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
      );

      inputData.updateFrom(other);
      expect(inputData, other);
      expect(testObserver.timesUpdated, 1);
    });

    test('Should throw CannotUpdateFromTypeException for a different InputData type', () {
      final other = InputData<int, int>(input: 42);

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
      final prefilled = InputData<String, int>(input: 'initial');
      expect(prefilled.hasInput, isTrue);
      expect(prefilled.input, 'initial');
      expect(testObserver.timesUpdated, 0);
    });
  });
}
