// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _TestStore store;
  late Observer observer;
  late int publishCallsCount;

  setUp(() {
    publishCallsCount = 0;
    store = _TestStore();
    observer = Observer(() {
      publishCallsCount += 1;
    });

    store.observers.add(observer);
  });

  test(
    'Should only notify listeners when publish method is called and once after init is called',
    () {
      // should be one publish call count since after observer is added init callback is called.
      expect(publishCallsCount, 1);

      store.age.value = 0;
      store.operation = Operation.none;
      store.failure = Failure('some error message!!!!!');
      store.userName.operation = Operation.read;
      store.points.failure = Failure('failed to get points');

      expect(publishCallsCount, 1);

      store.publish();

      expect(publishCallsCount, 2);
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

  group('Lifecycle callbacks', () {
    test(
      'onInstantiate should be called when store is created',
      () async {
        bool onInstantiateCalled = false;
        _TestStore(
          onInstantiateCallback: () async {
            onInstantiateCalled = true;
          },
        );

        // Wait a bit for the async onInstantiate to complete
        await Future.delayed(const Duration(milliseconds: 10));

        expect(onInstantiateCalled, isTrue);
      },
    );

    test(
      'init should be called when first observer is added',
      () async {
        bool initCalled = false;
        final testStore = _TestStore(
          initCallback: () async {
            initCalled = true;
          },
        );

        expect(initCalled, isFalse);

        final testObserver = Observer(() {});
        testStore.observers.add(testObserver);

        // Wait for init to complete
        await testStore.ensureInitialized();

        expect(initCalled, isTrue);
      },
    );

    test(
      'init should only be called once even if multiple observers are added',
      () async {
        int initCallCount = 0;
        final testStore = _TestStore(
          initCallback: () async {
            initCallCount++;
          },
        );

        final observer1 = Observer(() {});
        final observer2 = Observer(() {});
        final observer3 = Observer(() {});

        testStore.observers.add(observer1);
        await testStore.ensureInitialized();

        testStore.observers.add(observer2);
        testStore.observers.add(observer3);

        // Wait a bit to ensure no additional calls
        await Future.delayed(const Duration(milliseconds: 10));

        expect(initCallCount, 1);
      },
    );

    test(
      'onObserverAdded should be called when observer is added',
      () {
        final addedObservers = <Observer>[];
        final testStore = _TestStore(
          onObserverAddedCallback: (observer) {
            addedObservers.add(observer);
          },
        );

        final observer1 = Observer(() {});
        final observer2 = Observer(() {});

        testStore.observers.add(observer1);
        testStore.observers.add(observer2);

        expect(addedObservers.length, 2);
        expect(addedObservers[0], observer1);
        expect(addedObservers[1], observer2);
      },
    );

    test(
      'onObserverRemoved should be called when observer is removed',
      () {
        final removedObservers = <Observer>[];
        final testStore = _TestStore(
          onObserverRemovedCallback: (observer) {
            removedObservers.add(observer);
          },
        );

        final observer1 = Observer(() {});
        final observer2 = Observer(() {});

        testStore.observers.add(observer1);
        testStore.observers.add(observer2);

        testStore.observers.remove(observer1);
        testStore.observers.remove(observer2);

        expect(removedObservers.length, 2);
        expect(removedObservers[0], observer1);
        expect(removedObservers[1], observer2);
      },
    );

    test(
      'clear should be called when last observer is removed',
      () {
        bool clearCalled = false;
        final testStore = _TestStore(
          clearCallback: () {
            clearCalled = true;
          },
        );

        final observer1 = Observer(() {});
        final observer2 = Observer(() {});

        testStore.observers.add(observer1);
        testStore.observers.add(observer2);

        expect(clearCalled, isFalse);

        testStore.observers.remove(observer1);
        expect(clearCalled, isFalse);

        testStore.observers.remove(observer2);
        expect(clearCalled, isTrue);
      },
    );

    test(
      'clear should not be called when observers remain after removal',
      () {
        bool clearCalled = false;
        final testStore = _TestStore(
          clearCallback: () {
            clearCalled = true;
          },
        );

        final observer1 = Observer(() {});
        final observer2 = Observer(() {});

        testStore.observers.add(observer1);
        testStore.observers.add(observer2);

        testStore.observers.remove(observer1);

        expect(clearCalled, isFalse);
      },
    );
  });

  group('ensureInitialized', () {
    test(
      'should complete when init completes',
      () async {
        final completer = Completer<void>();
        final testStore = _TestStore(
          initCallback: () async {
            await Future.delayed(const Duration(milliseconds: 50));
            completer.complete();
          },
        );

        final observer1 = Observer(() {});
        testStore.observers.add(observer1);

        await testStore.ensureInitialized();

        expect(completer.isCompleted, isTrue);
      },
    );

    test(
      'should return the same future for multiple calls',
      () async {
        final testStore = _TestStore();
        final observer1 = Observer(() {});

        testStore.observers.add(observer1);

        final future1 = testStore.ensureInitialized();
        final future2 = testStore.ensureInitialized();

        expect(future1, future2);

        // Both futures are the same reference, so awaiting one completes both
        await future1;
        await future2; // This should complete immediately since it's the same future
      },
    );
  });
}

class _TestStore extends Store {
  final userName = Data<String>(value: 'alireza');
  final age = Data<int>();
  final points = Data<double>();

  // this field should not cause a rebuild, since it is not part of the states
  var nonData = 'something';

  final Future<void> Function()? onInstantiateCallback;
  final Future<void> Function()? initCallback;
  final void Function(Observer)? onObserverAddedCallback;
  final void Function(Observer)? onObserverRemovedCallback;
  final void Function()? clearCallback;

  _TestStore({
    this.onInstantiateCallback,
    this.initCallback,
    this.onObserverAddedCallback,
    this.onObserverRemovedCallback,
    this.clearCallback,
  });

  @override
  List<Data<Object?>> get states => [userName, age, points];

  @override
  Future<void> onInstantiate() async {
    await onInstantiateCallback?.call();
  }

  @override
  Future<void> init() async {
    await initCallback?.call();
  }

  @override
  void onObserverAdded(Observer observer) {
    onObserverAddedCallback?.call(observer);
  }

  @override
  void onObserverRemoved(Observer observer) {
    onObserverRemovedCallback?.call(observer);
  }

  @override
  void clear() {
    clearCallback?.call();
  }
}
