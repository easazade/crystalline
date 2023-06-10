import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  late ListData<String> listData;

  late List<Data<String>> items1;

  late List<Data<String>> items2;

  Data<String> singleItem = Data(value: 'tomato');

  final observer = () {};

  setUp(() {
    listData = ListData([]);
    items1 = ['apple', 'orange', 'ananas', 'banana']
        .map((e) => Data(value: e))
        .toList();
    items2 = ['book', 'pencil', 'eraser'].map((e) => Data(value: e)).toList();
    singleItem = Data(value: 'tomato');
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
  });

  test('Should add Item', () {
    expect(listData.length, 0);
    listData.add(singleItem);
    expect(listData.length, 1);
    expect(listData.first, singleItem);
  });

  test('Should add all Item', () {
    expect(listData.length, 0);
    listData.addAll(items1);
    expect(listData.length, items1.length);
    expect(listData.first, items1.first);
    expect(listData.items, items1);
  });

  test('Should remove Item', () {
    listData.addAll(items1);
    final firstItem = listData.first;
    final removedItem = listData.removeAt(0);
    expect(removedItem, firstItem);
  });

  test('Should modify list', () {
    listData.addAll(items1);
    expect(listData.items, items1);
    listData.modify((items) => items2);
    expect(listData.items, items2);
  });

  test('Should modify list async', () async {
    listData.addAll(items1);
    expect(listData.items, items1);
    await listData.modifyAsync((items) => Future.value(items2));
    expect(listData.items, items2);
  });

  test('Should add observer on list and all its items using addObserver', () {
    listData.addAll(items1);
    expect(listData.items, items1);

    // items should have no observer
    listData.forEach((e) => expect(e.observers, isEmpty));

    // when added an observer it should be added on all data items
    listData.addObserver(observer);
    items1.forEach((e) => expect(e.observers, contains(observer)));
  });

  test(
    'Should remove observer on list and all its items using removeObserver()',
    () {
      listData.addAll(items1);
      expect(listData.items, items1);

      // items should have no observer
      listData.forEach((e) => expect(e.observers, isEmpty));

      // when added an observer it should be added on all data items
      listData.addObserver(observer);
      items1.forEach((e) => expect(e.observers, contains(observer)));
      expect(listData.observers, contains(observer));

      // when removed an observer it should be removed from all data items and ListData itself
      listData.removeObserver(observer);
      items1.forEach((e) => expect(e.observers, isEmpty));
      expect(listData.observers, isEmpty);
    },
  );

  test('Should modify list and remvoe observers from old list', () {
    listData.addAll(items1);
    expect(listData.items, items1);

    // items should have no observer
    listData.forEach((e) => expect(e.observers, isEmpty));

    // when added an observer it should be added on all data items
    listData.addObserver(observer);
    items1.forEach((e) => expect(e.observers, contains(observer)));

    // when moyfied list and remove some items
    listData.modify((items) => items2);

    // expect observer should be removed from removed items
    items1.forEach((e) => expect(e.observers, isEmpty));

    // expect new items should have the observer
    items2.forEach((e) => expect(e.observers, contains(observer)));
  });

  test('Should add observer to new item after it is added', () {
    expect(singleItem.observers, isEmpty);
    listData.addAll(items1);
    listData.addObserver(observer);
    listData.add(singleItem);
    expect(singleItem.observers, contains(observer));
  });

  test(
    'Should add observer to new item after it is added using insert method',
    () {
      expect(singleItem.observers, isEmpty);
      listData.addAll(items1);
      listData.addObserver(observer);
      listData.insert(0, singleItem);
      expect(singleItem.observers, contains(observer));
    },
  );

  test('Should remove observer from removed item', () {
    listData.addObserver(observer);
    listData.add(singleItem);
    expect(singleItem.observers, contains(observer));
    listData.removeAt(0);
    expect(singleItem.observers, isEmpty);
  });

  test('Should notify observers when a single item is udpated', () {
    final expectedValue = 'peach!!';
    String actualValue = '';

    listData.add(singleItem);
    listData.addObserver(() => actualValue = listData[0].value);

    singleItem.value = expectedValue;

    expect(actualValue, expectedValue);
  });

  test('Should notify observers when a single item operation is updated', () {
    final expectedOperation = Operation.loading;
    Operation? actualOperation;

    listData.add(singleItem);
    listData.addObserver(() => actualOperation = listData[0].operation);

    singleItem.operation = expectedOperation;
    expect(actualOperation, expectedOperation);
  });

  test('Should notify observers when item in list has an error', () {
    final expectedError = DataError('message', Exception('message of'));
    DataError? actualError;

    listData.add(singleItem);
    listData.addObserver(() => actualError = listData[0].error);

    singleItem.error = expectedError;
    expect(actualError, expectedError);
  });

  test(
    'Should remove items where predicate matches using where removeWhere',
    () {
      final bar = Data(value: 'bar');
      final foo = Data(value: 'foo');
      listData.addAll([foo, bar]);
      listData.removeWhere((e) => e.value == 'foo');
      expect(listData[0], bar);
    },
  );
}
