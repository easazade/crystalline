import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _TestStore store;
  late VoidCallback listener;
  late int publishCallsCount;

  setUp(() {
    publishCallsCount = 0;
    store = _TestStore();
    listener = () {
      publishCallsCount += 1;
    };

    store.addListener(listener);
  });

  test(
    'Should only notify listeners when publish method is called',
    () {
      expect(publishCallsCount, 0);

      store.age.value = 0;
      store.operation = Operation.none;
      store.failure = Failure('some error message!!!!!');
      store.userName.operation = Operation.read;
      store.points.failure = Failure('failed to get points');

      expect(publishCallsCount, 0);

      store.publish();

      expect(publishCallsCount, 1);
    },
  );

  test(
    'Should only notify listeners when publish method is called',
    () {
      expect(publishCallsCount, 0);

      store.age.value = 0;
      store.operation = Operation.none;
      store.failure = Failure('some error message!!!!!');
      store.userName.operation = Operation.read;
      store.points.failure = Failure('failed to get points');

      expect(publishCallsCount, 0);

      store.publish();

      expect(publishCallsCount, 1);
    },
  );

  test(
    'toString should contain the states and should not contain data out of the state',
    () {
      store.age.value = 0;
      store.operation = Operation.create;
      store.failure = Failure('some error message!!!!!');
      store.userName.operation = Operation.read;
      store.points.failure = Failure('failed to get points');
      // this should not be shown in Store.toString() result since it is
      // not part of state
      store.nonData = 'Non data';

      final toString = store.toString();

      expect(toString, contains('0'));
      expect(toString, contains('create'));
      expect(toString, contains('some error message!!!!!'));
      expect(toString, contains('read'));
      expect(toString, contains('failed to get points'));
      expect(toString, isNot(contains('Non data')));
    },
  );
}

class _TestStore extends Store {
  final userName = Data<String>(value: 'alireza');
  final age = Data<int>();
  final points = Data<double>();

  // this field should not cause a rebuild, since it is not part of the states
  var nonData = 'something';

  @override
  String get storeName => 'TestStore';

  @override
  List<Data<Object?>> get states => [userName, age, points];
}
