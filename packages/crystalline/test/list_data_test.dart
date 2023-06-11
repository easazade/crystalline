import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late ListData<String> listData;
  late List<Data<String>> items1;
  late List<Data<String>> items2;
  late Data<String> singleItem;
  late ListDataTestObserver<String> testObserver;
  final observer = () {};

  setUp(() {
    listData = ListData([]);
    items1 = ['apple', 'orange', 'ananas', 'banana']
        .map((e) => Data(value: e))
        .toList();
    items2 = ['book', 'pencil', 'eraser'].map((e) => Data(value: e)).toList();
    singleItem = Data(value: 'tomato');
    testObserver = DataTestObserver(listData);
  });

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

  test('Should modify list', () {
    listData.addAll(items1);
    expect(listData.items, items1);
    listData.modify((items) => items2);
    expect(listData.items, items2);
    expect(testObserver.timesUpdated, 2);
  });

  test('Should modify list async', () async {
    listData.addAll(items1);
    expect(listData.items, items1);
    await listData.modifyAsync((items) => Future.value(items2));
    expect(listData.items, items2);
    expect(testObserver.timesUpdated, 2);
  });

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
      listData.forEach((e) => expect(e.observers.contains(observer), isFalse));

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

  test('Should modify list and remvoe observers from old list', () {
    listData.addAll(items1);
    expect(listData.items, items1);

    // items should have no observer
    listData.forEach((e) => expect(e.observers.contains(observer), isFalse));

    // when added an observer it should be added on all data items
    listData.addObserver(observer);
    items1.forEach((e) => expect(e.observers, contains(observer)));

    // when moyfied list and remove some items
    listData.modify((items) => items2);

    // expect observer should be removed from removed items
    items1.forEach((e) => expect(e.observers.contains(observer), isFalse));

    // expect new items should have the observer
    items2.forEach((e) => expect(e.observers, contains(observer)));
    expect(testObserver.timesUpdated, 2);
  });

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

  test('Should remove observer from removed item', () {
    listData.addObserver(observer);
    listData.add(singleItem);
    expect(singleItem.observers, contains(observer));
    listData.removeAt(0);
    expect(singleItem.observers, isEmpty);
    expect(testObserver.timesUpdated, 2);
  });

  test('Should notify observers when a single item is udpated', () {
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
    final expectedOperation = Operation.loading;

    listData.add(singleItem);

    singleItem.operation = expectedOperation;
    testObserver.expectNthUpdate(2, (list) {
      expect(list.first.operation, expectedOperation);
      expect(list.first.operation, listData.first.operation);
    });
    expect(testObserver.timesUpdated, 2);
  });

  test('Should notify observers when item in list has an error', () {
    final expectedError = DataError('message', Exception('message of'));

    listData.add(singleItem);

    singleItem.error = expectedError;
    testObserver.expectNthUpdate(2, (list) {
      expect(list.first.error, expectedError);
      expect(list.first.error, listData.first.error);
    });
    expect(testObserver.timesUpdated, 2);
  });

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
}
