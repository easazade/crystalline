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

    test('Should throw Failure when failure of Data is null and getter failure is called', () {
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
        expect(() => data.consumeFailure, throwsA(isA<FailureIsNullException>()));
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
        expect(newData.observers.hasObservers, isFalse);
        newData.observers.add(Observer(() {}));
        expect(newData.observers.all.length, 1);
        expect(newData.observers.hasObservers, isTrue);
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
          data.failure = Failure('oops!', id: 'ID-2', exception: e, stacktrace: stacktrace);

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
      expect(data.sideEffects.all.length, equals(1));
      expect(data.sideEffects.all, equals(['effect1']));
      expect(data.operation, Operation.read);
      expect(data.failureOrNull?.message, 'error message');
      expect(data.name, dataName);

      data.reset();

      expect(data.hasValue, isFalse);
      expect(data.sideEffects.isNotEmpty, isFalse);
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
      data.sideEffects.add(sideEffect);

      expect(data.sideEffects.all.length, 1);
      expect(data.sideEffects.all.firstOrNull, sideEffect);
      expect(testObserver.timesUpdated, 1);
    });

    test('Should remove a side effect', () {
      final sideEffect = 'effect on the side';
      data.sideEffects.add(sideEffect);
      expect(data.sideEffects.all.length, 1);

      data.sideEffects.remove(sideEffect);
      expect(data.sideEffects.all.length, 0);
      expect(testObserver.timesUpdated, 2);
    });

    test('Should add a list of side effects', () {
      final sideEffects = ['effect1', 'effect2', 14, 4.5];

      data.sideEffects.addAll(sideEffects);
      expect(data.sideEffects.all.length, 4);
      expect(data.sideEffects.all, sideEffects);
      expect(testObserver.timesUpdated, 1);
    });

    test('Should clear all side effects', () {
      final sideEffects = ['effect1', 'effect2', 14, 4.5];
      data.sideEffects.addAll(sideEffects);
      expect(data.sideEffects.all.length, 4);

      data.sideEffects.clear();
      expect(data.sideEffects.all, isEmpty);
      expect(testObserver.timesUpdated, 2);
    });

    test(
      'data.hasSideEffects should return true when there are side effects and vise versa',
      () {
        expect(data.sideEffects.isNotEmpty, isFalse);
        data.sideEffects.addAll(['effect1', 'effect2', 14, 4.5]);
        expect(data.sideEffects.isNotEmpty, isTrue);
      },
    );
  });

  group('extension -', () {
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
        expect(someData.events.hasListeners, isFalse);

        bool listener(event) => false;

        someData.events.addListener(listener);

        expect(someData.events.hasListeners, isTrue);
        expect(someData.events.listeners.length, equals(1));

        someData.events.removeListener(listener);

        expect(someData.events.hasListeners, isFalse);
      },
    );

    test(
      'data.dispatch() should dispatch all events successfully and in order',
      () {
        final event1 = Event('1');
        final event2 = Event('2');
        final event3 = Event('3');

        data.events.dispatch(event1);
        data.events.dispatch(event2);
        data.events.dispatch(event3);

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
        data.sideEffects.add('effect');

        testListener.expectNthDispatch(
          1,
          (event) => expect(
            event,
            AddSideEffectEvent(newSideEffect: 'effect', sideEffects: ['effect']),
          ),
        );

        testListener.expectNthDispatch(
          2,
          (event) => expect(event, SideEffectsUpdatedEvent(['effect'])),
        );

        data.sideEffects.remove('effect');

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
          data.sideEffects.add('effect');
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
          (event) => expect(event, FailureEvent(Failure('This is ERROR message !!!'))),
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
          data.sideEffects.add('effect');
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
          (event) => expect(event, FailureEvent(Failure('This is ERROR message !!!'))),
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
        data.sideEffects.add('effect');

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
          (event) => expect(event, FailureEvent(Failure('This is ERROR message !!!'))),
        );

        testListener2.expectNthDispatch(
          4,
          (event) => expect(event, SideEffectsUpdatedEvent(['effect'])),
        );
      },
    );
  });

  group('stream -', () {
    test('should emit when value is set', () async {
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.value = 'hello';

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 1);
      expect(emitted.first, same(data));
      expect(emitted.first.value, 'hello');
    });

    test('should emit when operation is set', () async {
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.operation = Operation.create;

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 1);
      expect(emitted.first.operation, Operation.create);
    });

    test('should emit when failure is set', () async {
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      final failure = Failure('error message');
      data.failure = failure;

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 1);
      expect(emitted.first.failureOrNull, failure);
    });

    test('should emit when side effect is added', () async {
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.sideEffects.add('effect1');

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 1);
      expect(emitted.first.sideEffects.all, ['effect1']);
    });

    test('should emit multiple times for multiple changes', () async {
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.value = 'first';
      data.operation = Operation.read;
      data.value = 'second';

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 3);
    });

    test('should emit only once when modify is used for bulk changes', () async {
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.modify((d) {
        d.value = 'apple';
        d.operation = Operation.create;
        d.failure = Failure('oops');
        d.sideEffects.add('effect');
      });

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 1);
    });

    test('should emit only once when modifyAsync is used for bulk changes', () async {
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      await data.modifyAsync((d) async {
        d.value = 'async';
        d.operation = Operation.update;
        d.sideEffects.add('async-effect');
      });

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 1);
    });

    test('should emit when updateFrom is called', () async {
      final source = Data<String>(
        value: 'from source',
        operation: Operation.read,
        sideEffects: ['source-effect'],
      );
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.updateFrom(source);

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.length, 1);
      expect(emitted.first.value, 'from source');
    });

    test('should support multiple listeners (broadcast)', () async {
      final emitted1 = <Data<String>>[];
      final emitted2 = <Data<String>>[];
      data.stream.listen(emitted1.add);
      data.stream.listen(emitted2.add);

      data.value = 'broadcast test';

      //a simple trick for waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted1.length, 1);
      expect(emitted2.length, 1);
      expect(emitted1.first.value, 'broadcast test');
      expect(emitted2.first.value, 'broadcast test');
    });

    test('should emit Data instance with current state', () async {
      data.value = 'initial';
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.value = 'updated';
      // waiting for listen callback to complete.
      await Future<void>.value();

      expect(emitted.single.value, 'updated');
    });

    test('should still emit if oldData equals to newData', () async {
      final initialDataHash = data.hashCode;
      final emitted = <Data<String>>[];
      data.stream.listen(emitted.add);

      data.value = 'updated';
      final oldDataHash = data.hashCode;
      data.value = 'updated';
      final newDataHash = data.hashCode;

      // waiting for listen callback to complete.
      await Future<void>.value();

      expect(initialDataHash, isNot(equals(newDataHash)));
      expect(oldDataHash, equals(newDataHash));
      expect(emitted.length, 2);
    });
  });
}
