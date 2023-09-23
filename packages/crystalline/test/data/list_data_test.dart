import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  late ListData<String> listData;
  late List<Data<String>> items1;
  late List<Data<String>> items2;
  late Data<String> singleItem;
  late ListDataTestObserver<String> testObserver;
  late ListDataTestEventListener<String> testListener;
  final observer = () {};

  setUp(() {
    listData = ListData([]);
    items1 = ['apple', 'orange', 'ananas', 'banana']
        .map((e) => Data(value: e))
        .toList();
    items2 = ['book', 'pencil', 'eraser'].map((e) => Data(value: e)).toList();
    singleItem = Data(value: 'tomato');
    testObserver = DataTestObserver(listData);
    testListener = DataTestListener(listData);
  });

  group('basic -', () {
    test('Should return correct length of items', () {
      expect(listData.length, 0);
      listData = ListData(items1);
      expect(listData.length, items1.length);
      listData = ListData(items2);
      expect(listData.length, items2.length);
    });

    test('Should insert Item', () {
      expect(listData.length, 0);
      listData.insert(0, singleItem);
      expect(listData.length, 1);
      expect(listData.first, singleItem);
      expect(testObserver.timesUpdated, 1);
    });

    test('Should add Item', () {
      expect(listData.length, 0);
      listData.add(singleItem);
      expect(listData.length, 1);
      expect(listData.first, singleItem);
      expect(testObserver.timesUpdated, 1);
    });

    test('Should add all Item', () {
      expect(listData.length, 0);
      listData.addAll(items1);
      expect(listData.length, items1.length);
      expect(listData.first, items1.first);
      expect(listData.items, items1);
      expect(testObserver.timesUpdated, 1);
    });

    test('Should remove Item', () {
      listData.addAll(items1);
      final firstItem = listData.first;
      final removedItem = listData.removeAt(0);
      expect(removedItem, firstItem);
      expect(testObserver.timesUpdated, 2);
    });
  });

  group('bulk -', () {
    test('Should modify list', () {
      listData.addAll(items1);
      expect(listData.items, items1);
      listData.modifyItems((items) => items2);
      expect(listData.items, items2);
      expect(testObserver.timesUpdated, 2);
    });

    test('Should modify list async', () async {
      listData.addAll(items1);
      expect(listData.items, items1);
      await listData.modifyItemsAsync((items) => Future.value(items2));
      expect(listData.items, items2);
      expect(testObserver.timesUpdated, 2);
    });

    test('Should modify list-data and call observers only once', () {
      listData.modify((data) {
        data.value.add(Data(value: 'apple'));
        data.value.add(Data(value: 'orange'));
        data.operation = Operation.create;
        data.failure = Failure('message');
      });

      expect(testObserver.timesUpdated, 1);
    });

    test(
      'Should modify list-data asynchronously and call observers only once',
      () async {
        await listData.modifyAsync((data) async {
          data.value.add(Data(value: 'apple'));
          data.value.add(Data(value: 'orange'));
          data.operation = Operation.create;
          data.failure = Failure('message');
        });

        expect(testObserver.timesUpdated, 1);
      },
    );

    test('Should modify list and remove observers from old list', () {
      listData.addAll(items1);
      expect(listData.items, items1);

      // items should have no observer
      listData.forEach((e) => expect(e.observers.contains(observer), isFalse));

      // when added an observer it should be added on all data items
      listData.addObserver(observer);
      items1.forEach((e) => expect(e.observers, contains(observer)));

      // when modified list and remove some items
      listData.modifyItems((items) => items2);

      // expect observer should be removed from removed items
      items1.forEach((e) => expect(e.observers.contains(observer), isFalse));

      // expect new items should have the observer
      items2.forEach((e) => expect(e.observers, contains(observer)));
      expect(testObserver.timesUpdated, 2);
    });

    test(
      'Should throw an exception when trying to set items on listdata using value setter method',
      () async {
        expect(() => listData.value = [], throwsA(isA<Exception>()));
      },
    );

    test(
      'Should copy the list successfully',
      () {
        final bar = Data(value: 'bar');
        final foo = Data(value: 'foo');
        listData.addAll([foo, bar]);

        final cloneList = listData.copy();

        expect(cloneList, listData);
        expect(testObserver.timesUpdated, 1);
      },
    );

    test(
      'Should create a new ListData instance with initial sideEffects',
      () {
        final sideEffects = ['side effect'];
        final list = ListData<int>([], sideEffects: sideEffects);

        expect(list.sideEffects, sideEffects);
      },
    );
  });

  group('observers -', () {
    test('Should add observer on list and all its items using addObserver', () {
      listData.addAll(items1);
      expect(listData.items, items1);

      // items should have no observer
      listData.forEach((e) => expect(e.observers.contains(observer), isFalse));

      // when added an observer it should be added on all data items
      listData.addObserver(observer);
      items1.forEach((e) => expect(e.observers, contains(observer)));
      expect(testObserver.timesUpdated, 1);
    });

    test(
      'Should remove observer on list and all its items using removeObserver()',
      () {
        listData.addAll(items1);
        expect(listData.items, items1);

        // items should have no observer
        listData
            .forEach((e) => expect(e.observers.contains(observer), isFalse));

        // when added an observer it should be added on all data items
        listData.addObserver(observer);
        items1.forEach((e) => expect(e.observers, contains(observer)));
        expect(listData.observers, contains(observer));

        // when removed an observer it should be removed from all data items and ListData itself
        listData.removeObserver(observer);
        items1.forEach((e) => expect(e.observers.contains(observer), isFalse));
        expect(listData.observers.contains(observer), isFalse);
        expect(testObserver.timesUpdated, 1);
      },
    );

    test('Should add observer to new item after it is added', () {
      expect(singleItem.observers, isEmpty);
      listData.addAll(items1);
      listData.addObserver(observer);
      listData.add(singleItem);
      expect(singleItem.observers, contains(observer));
      expect(testObserver.timesUpdated, 2);
    });

    test(
      'Should add observer to new item after it is added using insert method',
      () {
        expect(singleItem.observers, isEmpty);
        listData.addAll(items1);
        listData.addObserver(observer);
        listData.insert(0, singleItem);
        expect(singleItem.observers, contains(observer));
        expect(testObserver.timesUpdated, 2);
      },
    );

    test(
      'Should add observer to new item after it is added using [] operator',
      () {
        expect(singleItem.observers, isEmpty);
        listData.addAll(items1);
        listData.addObserver(observer);
        listData[0] = singleItem;
        expect(singleItem.observers, contains(observer));
        expect(testObserver.timesUpdated, 2);
      },
    );

    test('Should remove observer from removed item', () {
      listData.addObserver(observer);
      listData.add(singleItem);
      expect(singleItem.observers, contains(observer));
      listData.removeAt(0);
      expect(singleItem.observers, isEmpty);
      expect(testObserver.timesUpdated, 2);
    });

    test('Should notify observers when a single item is updated', () {
      final expectedValue = 'peach!!';
      listData.add(singleItem);

      singleItem.value = expectedValue;
      testObserver.expectNthUpdate(2, (list) {
        expect(list.first.value, expectedValue);
        expect(list.first.value, listData.first.value);
      });

      expect(testObserver.timesUpdated, 2);
    });

    test('Should notify observers when a single item operation is updated', () {
      final expectedOperation = Operation.operating;

      listData.add(singleItem);

      singleItem.operation = expectedOperation;
      testObserver.expectNthUpdate(2, (list) {
        expect(list.first.operation, expectedOperation);
        expect(list.first.operation, listData.first.operation);
      });
      expect(testObserver.timesUpdated, 2);
    });

    test('Should notify observers when item in list has an failure', () {
      final expectedFailure = Failure('message');

      listData.add(singleItem);

      singleItem.failure = expectedFailure;
      testObserver.expectNthUpdate(2, (list) {
        expect(list.first.failure, expectedFailure);
        expect(list.first.failure, listData.first.failure);
      });
      expect(testObserver.timesUpdated, 2);
    });
  });

  group('Iterable<T> overridden methods -', () {
    test(
      'Should remove items where predicate matches using where removeWhere',
      () {
        final bar = Data(value: 'bar');
        final foo = Data(value: 'foo');
        listData.addAll([foo, bar]);
        listData.removeWhere((e) => e.value == 'foo');
        expect(listData[0], bar);
        expect(listData.length, 1);
        expect(testObserver.timesUpdated, 2);
      },
    );

    test(
      'Should remove all items using removeAll() method',
      () {
        final bar = Data(value: 'bar');
        final foo = Data(value: 'foo');
        listData.addAll([foo, bar]);

        expect(listData.length, 2);

        listData.removeAll();

        expect(listData.length, 0);
        expect(testObserver.timesUpdated, 2);
      },
    );

    test(
      'Should set new items using [] operator',
      () {
        final bar = Data(value: 'bar');
        final foo = Data(value: 'foo');
        listData.addAll([foo]);
        expect(listData[0], foo);
        expect(listData.length, 1);

        listData[0] = bar;
        expect(listData[0], bar);
        expect(listData.length, 1);

        expect(testObserver.timesUpdated, 2);
      },
    );

    test(
      'Should update list-data from another list-data',
      () async {
        final otherData =
            ListData<String>([Data(value: 'shapoor'), Data(value: 'chancho')]);
        expect(listData, isNot(otherData));

        listData.updateFrom(otherData);
        expect(listData, otherData);

        expect(testObserver.timesUpdated, 1);
      },
    );
  });

  test(
    'failure and value flag methods for ListData should behave as default expected',
    () {
      expect(listData.hasFailure, isFalse);
      listData.failure = Failure('oops!');
      expect(listData.hasFailure, isTrue);

      expect(listData.hasValue, isFalse);
      expect(listData.hasNoValue, isTrue);
      listData.add(singleItem);
      expect(listData.hasValue, isTrue);
      expect(listData.hasNoValue, isFalse);
    },
  );

  group('behavior strategies -', () {
    test(
      'failure and value flag methods for ListData should behave as overridden '
      'and return false at all time since the override function just returns false',
      () {
        bool overrideFunc(
          List<Data<String>> value,
          Operation operation,
          Failure? failure,
        ) {
          return false;
        }

        listData = ListData<String>(
          [],
          hasValueStrategy: overrideFunc,
          hasNoValueStrategy: overrideFunc,
          hasFailureStrategy: overrideFunc,
        );

        expect(listData.hasFailure, isFalse);
        listData.failure = Failure('oops!');
        expect(listData.hasFailure, isFalse);

        expect(listData.hasValue, isFalse);
        expect(listData.hasNoValue, isFalse);
        listData.add(singleItem);
        expect(listData.hasValue, isFalse);
        expect(listData.hasNoValue, isFalse);
      },
    );

    test(
      'operation flag methods for ListData should behave as default expected',
      () {
        expect(listData.isOperating, isFalse);

        listData.operation = Operation.create;
        expect(listData.isCreating, isTrue);

        listData.operation = Operation.delete;
        expect(listData.isDeleting, isTrue);

        listData.operation = Operation.fetch;
        expect(listData.isFetching, isTrue);

        listData.operation = Operation.update;
        expect(listData.isUpdating, isTrue);

        listData.operation = Operation('add-to-cart');
        expect(listData.hasCustomOperation, isTrue);
      },
    );

    test(
      'operation flag methods for ListData should behave as overridden '
      'and return false at all time since the override function just returns false',
      () {
        bool overrideFunc(
          List<Data<String>> value,
          Operation operation,
          Failure? failure,
        ) {
          return false;
        }

        final listData = ListData<String>(
          [],
          isCreatingStrategy: overrideFunc,
          isDeletingStrategy: overrideFunc,
          isUpdatingStrategy: overrideFunc,
          isFetchingStrategy: overrideFunc,
          isOperatingStrategy: overrideFunc,
          hasCustomOperationStrategy: overrideFunc,
        );

        expect(listData.isOperating, isFalse);

        listData.operation = Operation.create;
        expect(listData.isCreating, isFalse);

        listData.operation = Operation.delete;
        expect(listData.isDeleting, isFalse);

        listData.operation = Operation.fetch;
        expect(listData.isFetching, isFalse);

        listData.operation = Operation.update;
        expect(listData.isUpdating, isFalse);

        listData.operation = Operation('add-to-cart');
        expect(listData.hasCustomOperation, isFalse);
      },
    );
  });

  group('events -', () {
    test(
      'ListData should dispatch correct event when operation updated',
      () {
        listData.operation = Operation.fetch;
        listData.operation = Operation.operating;

        testListener.expectNthDispatch(
          1,
          (event) => expect(event, OperationEvent(Operation.fetch)),
        );

        testListener.expectNthDispatch(
          2,
          (event) => expect(event, OperationEvent(Operation.operating)),
        );

        expect(testListener.timesDispatched, 2);
      },
    );

    test(
      'ListData should dispatch correct event when failure set and '
      'should not dispatch any event when failure set to null',
      () {
        listData.failure = Failure('message');

        testListener.expectNthDispatch(
          1,
          (event) => expect(event, FailureEvent(Failure('message'))),
        );

        listData.failure = null;

        expect(testListener.timesDispatched, 1);
      },
    );

    test(
      'should dispatch a SideEffectsUpdated event and AddSideEffectEvent '
      'and then a RemoveSideEffectEvent when side effect is removed from ListData',
      () {
        listData.addSideEffect('effect');

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
          (event) => expect(event, SideEffectsUpdated(['effect'])),
        );

        listData.removeSideEffect('effect');

        testListener.expectNthDispatch(
          3,
          (event) => expect(
            event,
            RemoveSideEffectEvent(removedSideEffect: 'effect', sideEffects: []),
          ),
        );

        testListener.expectNthDispatch(
          4,
          (event) => expect(event, SideEffectsUpdated([])),
        );
      },
    );

    test(
      'should dispatch AddItemEvent when an item added using [] operator',
      () {},
    );

    test(
      'should dispatch AddItemEvent when an item added using add() method',
      () {},
    );

    test(
      'should dispatch RemoveItemEvent when an item removed using removeAt() method',
      () {},
    );

    test(
      'should dispatch ItemsUpdatedEvent when all items removed using removeAll() method',
      () {},
    );

    test(
      'should dispatch ItemsUpdatedEvent when items added using addAll() method',
      () {},
    );

    test(
      'should dispatch ItemsUpdatedEvent when items removed using removeWhere() method',
      () {},
    );

    test(
      'should dispatch AddItemEvent when an item added using insert() method',
      () {},
    );

    test(
      'should dispatch ItemsUpdatedEvent when items added using addAll() method',
      () {},
    );

    test(
      'should dispatch correct semantic events when items modified using modifyItems',
      () {},
    );

    test(
      'should dispatch correct semantic events when items modified using modifyItemsAsync',
      () {},
    );

    test(
      'should dispatch correct semantic events when items modified using modify',
      () {},
    );

    test(
      'should dispatch correct semantic events when items modified using modifyAsync',
      () {},
    );

    test(
      'should dispatch correct semantic events when items modified using updateFrom',
      () {},
    );
  });
}
