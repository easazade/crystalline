import 'package:crystalline/crystalline.dart';
import 'package:crystalline/src/data_types/extensions.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late Data<String> data;
  late DataTestObserver<String, Data<String>> testObserver;

  setUp(() {
    data = Data();
    testObserver = DataTestObserver(data);
  });

  test('Should set value', () {
    expect(data.valueOrNull, isNull);
    final expectedValue = 'Some String';
    data.value = expectedValue;
    expect(data.value, expectedValue);
    expect(testObserver.timesUpdated, 1);
  });

  test(
    'Should throw Error when value of Data is null and getter value is called',
    () {
      expect(data.valueOrNull, isNull);
      expect(() => data.value, throwsA(isA<ValueNotAvailableException>()));
    },
  );

  test('Should set the operation', () {
    expect(data.operation, Operation.none);
    final expectedOperation = Operation.defaultOperations.randomItem!;
    data.operation = expectedOperation;
    expect(data.operation, expectedOperation);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should set error', () {
    expect(data.hasError, isFalse);
    final expectedError = Failure('message');
    data.error = expectedError;
    expect(data.error, expectedError);
    expect(testObserver.timesUpdated, 1);
  });

  test(
      'Should throw Error when error of Data is null and getter error is called',
      () {
    expect(data.hasError, isFalse);
    expect(() => data.error, throwsA(isA<ErrorIsNullException>()));
  });

  test(
    'Should return error and set error as null when data.consumeError is called',
    () {
      expect(data.hasError, isFalse);
      data.error = Failure('oops!, something wrong');
      expect(data.hasError, isTrue);
      final error = data.consumeError;
      expect(error.message, 'oops!, something wrong');
      expect(data.hasError, isFalse);
    },
  );

  test(
    'Should throw exception when data has no error and data.consumeError is called',
    () {
      expect(data.hasError, isFalse);
      expect(() => data.consumeError, throwsA(isA<ErrorIsNullException>()));
    },
  );

  test('Should modify data and call observers only once', () {
    data.modify((data) {
      data.value = 'apple';
      data.value = 'orage';
      data.operation = Operation.create;
      data.error = Failure('message');
    });

    expect(testObserver.timesUpdated, 1);
  });

  test(
    'Should modify data asynchronously and call observers only once',
    () async {
      await data.modifyAsync((data) async {
        data.value = 'apple';
        data.value = 'orage';
        data.operation = Operation.create;
        data.error = Failure('message');
      });

      expect(testObserver.timesUpdated, 1);
    },
  );

  test(
    'Should udpateData from another data',
    () async {
      final otherData = Data(value: 'subway');
      expect(data == otherData, isFalse);
      data.updateFrom(otherData);
      expect(data == otherData, isTrue);

      expect(testObserver.timesUpdated, 1);
    },
  );

  test(
    'Should return true on data.operation.isCustom when a custom '
    'operation is set on data and vise versa',
    () async {
      expect(data.operation.isCustom, false);

      data.operation = Operation('set-user-profile');
      expect(data.operation.isCustom, true);

      expect(testObserver.timesUpdated, 1);
    },
  );

  test(
    'Should return Operation.[name] when toString() is called',
    () async {
      data.operation = Operation.create;
      expect(data.operation.toString(), 'Operation.create');
    },
  );

  test(
    'data.hasValue should return true when there is value and vise versa',
    () {
      expect(data.hasValue, isFalse);
      data.value = 'meow';
      expect(data.hasValue, isTrue);
    },
  );

  test(
    'data.hasNoValue should return true when there is no value and vise versa',
    () {
      expect(data.hasNoValue, isTrue);
      data.value = 'meow';
      expect(data.hasNoValue, isFalse);
    },
  );

  test(
    'data.isCreating should return true when Operation.create is set',
    () {
      expect(data.isCreating, isFalse);
      data.operation = Operation.create;
      expect(data.isCreating, isTrue);
    },
  );

  test(
    'data.isDeleting should return true when Operation.delete is set',
    () {
      expect(data.isDeleting, isFalse);
      data.operation = Operation.delete;
      expect(data.isDeleting, isTrue);
    },
  );

  test(
    'data.isFetching should return true when Operation.fetch is set',
    () {
      expect(data.isFetching, isFalse);
      data.operation = Operation.fetch;
      expect(data.isFetching, isTrue);
    },
  );

  test(
    'data.isUpdating should return true when Operation.update is set',
    () {
      expect(data.isUpdating, isFalse);
      data.operation = Operation.update;
      expect(data.isUpdating, isTrue);
    },
  );

  test(
    'data.hasCustomOperation should return true when custom-operation is set',
    () {
      expect(data.hasCustomOperation, isFalse);
      data.operation = Operation('custom');
      expect(data.hasCustomOperation, isTrue);
    },
  );

  test(
    'data.isOperating should return true when operation is not Operation.none',
    () {
      expect(data.isOperating, isFalse);
      data.operation = Operation('custom');
      expect(data.isOperating, isTrue);
    },
  );

  test(
    'data.valueEqualsTo should return true when data.value equals otherValue',
    () {
      expect(data.valueEqualsTo('cat'), isFalse);
      data.value = 'cat';
      expect(data.valueEqualsTo('cat'), isTrue);
    },
  );

  test(
    'data.toString() should return expected info',
    () {
      try {
        throw Exception('oops');
      } catch (e, stacktrace) {
        data.value = 'cat';
        data.operation = Operation.create;
        data.error =
            Failure('oops!', id: 'ID-2', exception: e, stacktrace: stacktrace);

        final string = data.toString();
        expect(string, contains(data.operation.name));
        expect(string, contains(data.value.toString()));
        expect(string, contains(data.error.id));
        expect(string, contains(data.error.message));
        expect(string, contains(data.error.stacktrace.toString()));
        expect(string, contains(data.error.exception.toString()));
      }
    },
  );

  test(
    'data.toString() should return expected info for a data without any errors or value',
    () {
      final string = data.toString();
      expect(string, contains(data.operation.name));
      expect(string, contains(data.valueOrNull.toString()));
    },
  );

  test(
    'data.hasObservers should return true if it has any',
    () {
      final newData = Data<String>();
      expect(newData.hasObservers, isFalse);
      newData.addObserver(() {});
      expect(newData.observers.length, 1);
      expect(newData.hasObservers, isTrue);
    },
  );

  test('Should add a side effect', () {
    final sideEffect = 'effect on the side';
    data.addSideEffect(sideEffect);

    expect(data.sideEffects.length, 1);
    expect(data.sideEffects.firstOrNull, sideEffect);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should remove a side effect', () {
    final sideEffect = 'effect on the side';
    data.addSideEffect(sideEffect);
    expect(data.sideEffects.length, 1);

    data.removeSideEffect(sideEffect);
    expect(data.sideEffects.length, 0);
    expect(testObserver.timesUpdated, 2);
  });

  test('Should add a list of side effects', () {
    final sideEffects = ['effect1', 'effect2', 14, 4.5];

    data.addAllSideEffects(sideEffects);
    expect(data.sideEffects.length, 4);
    expect(data.sideEffects, sideEffects);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should clear all side effects', () {
    final sideEffects = ['effect1', 'effect2', 14, 4.5];
    data.addAllSideEffects(sideEffects);
    expect(data.sideEffects.length, 4);

    data.clearAllSideEffects();
    expect(data.sideEffects, isEmpty);
    expect(testObserver.timesUpdated, 2);
  });

  test(
    'data.hasSideEffects should return true when there are side effects and vise versa',
    () {
      expect(data.hasSideEffects, isFalse);
      data.addAllSideEffects(['effect1', 'effect2', 14, 4.5]);
      expect(data.hasSideEffects, isTrue);
    },
  );

  test(
    'data.unModifiable() extension should convert Data to UnModifiableData',
    () {
      expect(data.unModifiable(), isA<UnModifiableData<String>>());
    },
  );

  test(
    'data.toOperationData() extension should convert Data to an OperationData',
    () {
      expect(data.toOperationData(), isA<OperationData>());
    },
  );
}
