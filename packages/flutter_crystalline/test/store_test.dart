// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';

part 'store_test.crystalline.dart';

void main() {
  late TestStore store;
  late Observer observer;
  late int publishCallsCount;

  setUp(() {
    publishCallsCount = 0;
    store = TestStore();
    observer = Observer(() {
      publishCallsCount += 1;
    });

    store.observers.add(observer);
  });

  group('publish', () {
    test(
      'Should only notify listeners when publish method is called',
      () {
        // Publish is no longer auto-called after init; it falls to the user to call it.
        expect(publishCallsCount, 0);

        store.age.value = 0;
        store.operation = Operation.none;
        store.failure = Failure('some error message!!!!!');
        store.userName.operation = Operation.read;
        store.points.failure = Failure('failed to get points');

        expect(publishCallsCount, 0);

        store.publish();

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
  });

  group('Lifecycle callbacks', () {
    test(
      'onInstantiate should be called when store is created',
      () async {
        bool onInstantiateCalled = false;
        TestStore(
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
        final testStore = TestStore(
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
        final testStore = TestStore(
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
        final testStore = TestStore(
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
        final testStore = TestStore(
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
        final testStore = TestStore(
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
        final testStore = TestStore(
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

  group('stream', () {
    test(
      'should emit when store-level properties change and publish is called',
      () async {
        final testStore = TestStore();
        final emitted = <TestStore>[];
        testStore.stream.listen(emitted.add);

        testStore.observers.add(Observer(() {}));
        await testStore.ensureInitialized();

        expect(emitted.length, 0);

        testStore.operation = Operation.create;
        testStore.failure = Failure('error');
        testStore.sideEffects.add('effect');

        expect(emitted.length, 0);

        testStore.publish();

        await Future<void>.value();

        expect(emitted.length, 1);
        expect(emitted.last.operation, Operation.create);
        expect(emitted.last.failureOrNull?.message, 'error');
        expect(emitted.last.sideEffects.all, contains('effect'));
      },
    );

    test(
      'should only emit when publish is called, not on changes alone',
      () async {
        final testStore = TestStore();
        final emitted = <TestStore>[];
        testStore.stream.listen(emitted.add);

        testStore.observers.add(Observer(() {}));
        await testStore.ensureInitialized();

        expect(emitted.length, 0);

        testStore.age.value = 0;
        testStore.operation = Operation.none;
        testStore.failure = Failure('some error');
        testStore.userName.operation = Operation.read;
        testStore.points.failure = Failure('failed');
        testStore.sideEffects.add('effect1');
        testStore.sideEffects.add('effect2');

        await Future<void>.value();

        expect(emitted.length, 0);

        testStore.publish();

        await Future<void>.value();

        expect(emitted.length, 1);
      },
    );

    test(
      'should emit when child data properties change and publish is called, and again on subsequent change and publish',
      () async {
        final testStore = TestStore();
        final emitted = <TestStore>[];
        testStore.stream.listen(emitted.add);

        testStore.observers.add(Observer(() {}));
        await testStore.ensureInitialized();

        expect(emitted.length, 0);

        testStore.userName.value = 'updated';
        testStore.age.value = 42;
        testStore.points.value = 100.0;

        testStore.publish();

        await Future<void>.value();

        expect(emitted.length, 1);
        expect(emitted.last.userName.value, 'updated');
        expect(emitted.last.age.value, 42);
        expect(emitted.last.points.value, 100.0);

        testStore.userName.value = 'updated again';
        testStore.age.value = 99;

        testStore.publish();

        await Future<void>.value();

        expect(emitted.length, 2);
        expect(emitted.last.userName.value, 'updated again');
        expect(emitted.last.age.value, 99);
      },
    );

    test(
      'should emit for each publish when init overrides and calls publish multiple times',
      () async {
        late TestStore testStore;
        testStore = TestStore(
          initCallback: () async {
            testStore.publish();
            testStore.publish();
            testStore.publish();
          },
        );

        final observerCalls = <int>[];
        final emitted = <TestStore>[];

        testStore.stream.listen(emitted.add);
        testStore.observers.add(Observer(() {
          observerCalls.add(observerCalls.length + 1);
        }));

        await testStore.ensureInitialized();

        await Future<void>.value();

        expect(observerCalls.length, 3);
        expect(emitted.length, 3);
      },
    );
  });

  group('listenable', () {
    test(
      'should notify listeners when publish is called',
      () async {
        final testStore = TestStore();
        var notifyCount = 0;
        void listener() => notifyCount++;

        testStore.listenable.addListener(listener);
        testStore.observers.add(Observer(() {}));
        await testStore.ensureInitialized();

        expect(notifyCount, 0);

        testStore.operation = Operation.create;
        testStore.publish();

        await Future<void>.value();
        expect(notifyCount, 1);

        testStore.publish();

        await Future<void>.value();
        expect(notifyCount, 2);
        testStore.listenable.removeListener(listener);
      },
    );

    test(
      'should not notify after listener is removed',
      () async {
        final testStore = TestStore();
        var notifyCount = 0;
        void listener() => notifyCount++;

        testStore.listenable.addListener(listener);
        testStore.observers.add(Observer(() {}));
        await testStore.ensureInitialized();

        testStore.listenable.removeListener(listener);
        testStore.publish();
        await Future<void>.value();

        expect(notifyCount, 0);
      },
    );
  });

  group('ensureInitialized', () {
    test(
      'should complete when init completes',
      () async {
        final completer = Completer<void>();
        final testStore = TestStore(
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
        final testStore = TestStore();
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

@StoreClass()
abstract class _TestStore extends Store {
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
  Future<void> onInitialize() async {
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
