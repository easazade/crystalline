import 'package:collection/collection.dart';
import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../test_utils/test_logger.dart';
import '../utils.dart';

void main() {
  late Data<String> data;
  late DataTestObserver<String, Data<String>> testObserver;
  late DataTestListener<String, Data<String>> testListener;

  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    data = Data();
    testObserver = DataTestObserver(data);
    testListener = DataTestListener(data);
  });

  group('basic -', () {
    test('Should set value', () {
      expect(data.valueOrNull, isNull);
      final expectedValue = 'Some String';
      data.value = expectedValue;
      print(data);
      expect(data.value, expectedValue);
      expect(testObserver.timesUpdated, 1);
    });

    test(
      'Should throw Failure when value of Data is null and getter value is called',
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

    test('Should set failure', () {
      expect(data.hasFailure, isFalse);
      final expectedFailure = Failure('This is ERROR message !!!');
      data.failure = expectedFailure;
      expect(data.failure, expectedFailure);
      expect(testObserver.timesUpdated, 1);
    });

    test(
        'Should throw Failure when failure of Data is null and getter failure is called',
        () {
      expect(data.hasFailure, isFalse);
      expect(() => data.failure, throwsA(isA<FailureIsNullException>()));
    });

    test(
      'Should return failure and set failure as null when data.consumeFailure is called',
      () {
        expect(data.hasFailure, isFalse);
        data.failure = Failure('oops!, something wrong');
        expect(data.hasFailure, isTrue);
        final failure = data.consumeFailure;
        expect(failure.message, 'oops!, something wrong');
        expect(data.hasFailure, isFalse);
      },
    );

    test(
      'Should throw exception when data has no failure and data.consumeFailure is called',
      () {
        expect(data.hasFailure, isFalse);
        expect(
            () => data.consumeFailure, throwsA(isA<FailureIsNullException>()));
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
      'data.isReading should return true when Operation.read is set',
      () {
        expect(data.isReading, isFalse);
        data.operation = Operation.read;
        expect(data.isReading, isTrue);
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
      'data.isAnyOperation should return true when operation is not Operation.none',
      () {
        expect(data.isAnyOperation, isFalse);
        data.operation = Operation('custom');
        expect(data.isAnyOperation, isTrue);
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
      'data.hasObservers should return true if it has any',
      () {
        final newData = Data<String>();
        expect(newData.hasObservers, isFalse);
        newData.addObserver(() {});
        expect(newData.observers.length, 1);
        expect(newData.hasObservers, isTrue);
      },
    );

    test(
      'data.toString() should return expected info for a data without any failures or value',
      () {
        data = Data(name: 'varName');
        final string = data.toString();
        expect(string, contains(data.operation.name));
        expect(string, contains(data.valueOrNull.toString()));
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
          data.failure = Failure('oops!',
              id: 'ID-2', exception: e, stacktrace: stacktrace);

          final string = data.toString();
          expect(string, contains(data.operation.name));
          expect(string, contains(data.value.toString()));
          expect(string, contains(data.failure.id));
          expect(string, contains(data.failure.message));
          expect(string, contains(data.failure.stacktrace.toString()));
          expect(string, contains(data.failure.exception.toString()));
        }
      },
    );

    test(
      'data.toString() should call toString method without any errors and '
      'should show the correct data in the printed string',
      () {
        final value = 'hello';
        final errorMsg = 'some error message';
        final errorId = 'ERR-10';
        final causeOfError = Operation.delete;
        final operation = Operation.update;

        data.value = value;
        data.failure = Failure(errorMsg, id: errorId, cause: causeOfError);
        data.operation = operation;
        final string = data.toString();
        expect(string, isNotEmpty);
        expect(string, contains(value));
        expect(string, contains(errorId));
        expect(string, contains(errorMsg));
        expect(string, contains(causeOfError.name));
        expect(string, contains(operation.name));
      },
    );

    test(
      'Should create and name a data without any issues, the name '
      'should be printed in toString() result as well',
      () {
        final data = Data<int>(name: 'date-of-birth');
        print(data);
        expect(data.name, equals('date-of-birth'));
        expect(data.toString(), contains('date-of-birth'));
      },
    );

    test('Should reset data without any issue', () {
      final dataName = 'string-data';
      final data = Data<String>(
        value: 'ali',
        sideEffects: ['effect1'],
        operation: Operation.read,
        failure: Failure('error message'),
        name: dataName,
      );

      expect(data.value, 'ali');
      expect(data.sideEffects.length, equals(1));
      expect(data.sideEffects, equals(['effect1']));
      expect(data.operation, Operation.read);
      expect(data.failureOrNull?.message, 'error message');
      expect(data.name, dataName);

      data.reset();

      expect(data.hasValue, isFalse);
      expect(data.sideEffects.isEmpty, isTrue);
      expect(data.operation, Operation.none);
      expect(data.hasFailure, isFalse);
      // the data name should not change on reset. since it is just a name of the data
      expect(data.name, dataName);
    });
  });

  group('bulk -', () {
    test('Should modify data and call observers only once', () {
      data.modify((data) {
        data.value = 'apple';
        data.value = 'orange';
        data.operation = Operation.create;
        data.failure = Failure('This is ERROR message !!!');
      });

      expect(testObserver.timesUpdated, 1);
    });

    test(
      'Should modify data asynchronously and call observers only once',
      () async {
        await data.modifyAsync((data) async {
          data.value = 'apple';
          data.value = 'orange';
          data.operation = Operation.create;
          data.failure = Failure('This is ERROR message !!!');
        });

        expect(testObserver.timesUpdated, 1);
      },
    );

    test(
      'Should updateData from another data',
      () async {
        final otherData = Data(value: 'subway');
        expect(data, isNot(otherData));
        data.updateFrom(otherData);
        expect(data, otherData);

        expect(testObserver.timesUpdated, 1);
      },
    );
  });

  group('sideEffects -', () {
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

      data.removeAllSideEffects();
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
  });

  group('extension -', () {
    test(
      'data.unModifiable() extension should convert Data to ObservableData',
      () {
        expect(data.unModifiable(), isA<ObservableData<String>>());
      },
    );

    test(
      'data.mapToData extension should convert an Iterable<T> to a List<Data<T>>',
      () {
        final list = ['alireza', 'mohammad', 'sobhan', 'reza'];
        final dataList = list.mapToDataList();

        expect(list.length, dataList.length);
        final backToList = dataList.map((d) => d.value).toList();
        expect(ListEquality<String>().equals(list, backToList), isTrue);
      },
    );

    test(
      'data.toOperationData() extension should convert Data to an OperationData',
      () {
        expect(data.toOperationData(), isA<OperationData>());
      },
    );
  });

  group('events -', () {
    test(
      'data.addEventListener() should add/remove event listener successfully',
      () {
        final someData = Data<String>();
        expect(someData.hasEventListeners, isFalse);

        final listener = (event) => false;

        someData.addEventListener(listener);

        expect(someData.hasEventListeners, isTrue);
        expect(someData.eventListeners.length, equals(1));

        someData.removeEventListener(listener);

        expect(someData.hasEventListeners, isFalse);
      },
    );

    test(
      'data.dispatchEvent() should dispatch all events successfully and in order',
      () {
        final event1 = Event('1');
        final event2 = Event('2');
        final event3 = Event('3');

        data.dispatchEvent(event1);
        data.dispatchEvent(event2);
        data.dispatchEvent(event3);

        expect(testListener.timesDispatched, 3);
        testListener.expectNthDispatch(1, (event) => expect(event, event1));
        testListener.expectNthDispatch(2, (event) => expect(event, event2));
        testListener.expectNthDispatch(3, (event) => expect(event, event3));
      },
    );
  });

  group('semantic event -', () {
    test('should dispatch a ValueEvent with new value set', () {
      final newValue = 'new value';
      data.value = newValue;

      expect(testListener.timesDispatched, 1);
      testListener.expectNthDispatch(
        1,
        (event) {
          final expected = ValueEvent(newValue);
          expect(event, expected);
          expect(event.name, expected.name);
          expect(event.toString(), expected.toString());
        },
      );
    });

    test('should NOT dispatch a ValueEvent when new value is null', () {
      data.value = 'meow';
      expect(testListener.timesDispatched, 1);

      data.value = null;
      expect(testListener.timesDispatched, 1);
    });

    test('should dispatch an OperationEvent when operation updated', () {
      data.operation = Operation('upload-image');

      expect(testListener.timesDispatched, 1);
      testListener.expectNthDispatch(
        1,
        (event) => expect(event, OperationEvent(Operation('upload-image'))),
      );
    });

    test(
      'should dispatch a FailureEvent with new failure set and should not dispatch another event when '
      'failure is set to null afterwards',
      () {
        final newFailure = Failure('This is ERROR message !!!');
        data.failure = newFailure;

        expect(testListener.timesDispatched, 1);
        testListener.expectNthDispatch(
          1,
          (event) => expect(event, FailureEvent(newFailure)),
        );

        data.failure = null;

        expect(testListener.timesDispatched, 1);
      },
    );

    test(
      'should dispatch a SideEffectsUpdated event and AddSideEffectEvent '
      'and then a RemoveSideEffectEvent when side effect is removed',
      () {
        data.addSideEffect('effect');

        testListener.expectNthDispatch(
          1,
          (event) => expect(
            event,
            AddSideEffectEvent(
                newSideEffect: 'effect', sideEffects: ['effect']),
          ),
        );

        testListener.expectNthDispatch(
          2,
          (event) => expect(event, SideEffectsUpdatedEvent(['effect'])),
        );

        data.removeSideEffect('effect');

        testListener.expectNthDispatch(
          3,
          (event) => expect(
            event,
            RemoveSideEffectEvent(removedSideEffect: 'effect', sideEffects: []),
          ),
        );

        testListener.expectNthDispatch(
          4,
          (event) => expect(event, SideEffectsUpdatedEvent([])),
        );
      },
    );

    test(
      'should dispatch correct events after data.modify is called',
      () {
        data.modify((data) {
          data.value = 'meow';
          data.operation = Operation.delete;
          data.failure = Failure('This is ERROR message !!!');
          data.addSideEffect('effect');
        });

        testListener.expectNthDispatch(
          1,
          (event) => expect(event, ValueEvent('meow')),
        );

        testListener.expectNthDispatch(
          2,
          (event) => expect(event, OperationEvent(Operation.delete)),
        );

        testListener.expectNthDispatch(
          3,
          (event) =>
              expect(event, FailureEvent(Failure('This is ERROR message !!!'))),
        );

        testListener.expectNthDispatch(
          4,
          (event) => expect(event, SideEffectsUpdatedEvent(['effect'])),
        );
      },
    );

    test(
      'should dispatch correct events after data.modifyAsync is called',
      () async {
        await data.modifyAsync((data) async {
          data.value = 'meow';
          data.operation = Operation.delete;
          data.failure = Failure('This is ERROR message !!!');
          data.addSideEffect('effect');
        });

        testListener.expectNthDispatch(
          1,
          (event) => expect(event, ValueEvent('meow')),
        );

        testListener.expectNthDispatch(
          2,
          (event) => expect(event, OperationEvent(Operation.delete)),
        );

        testListener.expectNthDispatch(
          3,
          (event) =>
              expect(event, FailureEvent(Failure('This is ERROR message !!!'))),
        );

        testListener.expectNthDispatch(
          4,
          (event) => expect(event, SideEffectsUpdatedEvent(['effect'])),
        );
      },
    );

    test(
      'should dispatch correct events after data.updateFrom is called',
      () async {
        data.value = 'meow';
        data.operation = Operation.delete;
        data.failure = Failure('This is ERROR message !!!');
        data.addSideEffect('effect');

        final data2 = Data<String>();
        final testListener2 = DataTestListener<String, Data<String>>(data2);

        data2.updateFrom(data);

        testListener2.expectNthDispatch(
          1,
          (event) => expect(event, ValueEvent('meow')),
        );

        testListener2.expectNthDispatch(
          2,
          (event) => expect(event, OperationEvent(Operation.delete)),
        );

        testListener2.expectNthDispatch(
          3,
          (event) =>
              expect(event, FailureEvent(Failure('This is ERROR message !!!'))),
        );

        testListener2.expectNthDispatch(
          4,
          (event) => expect(event, SideEffectsUpdatedEvent(['effect'])),
        );
      },
    );
  });
}
