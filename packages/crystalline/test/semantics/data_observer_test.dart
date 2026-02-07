import 'package:crystalline/crystalline.dart';
import 'package:crystalline/src/internal/internal_observer.dart';
import 'package:test/test.dart';

import '../test_utils/test_logger.dart';

void main() {
  late Data<String> data;
  late DataObservers observers;

  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    data = Data();
    observers = data.observers;
  });

  group('add and remove -', () {
    test('Should add an observer', () {
      final observer = Observer(() {});

      expect(observers.all, isEmpty);
      observers.add(observer);
      expect(observers.all, contains(observer));
    });

    test('Should remove an observer', () {
      final observer = Observer(() {});

      observers.add(observer);
      expect(observers.all, contains(observer));

      observers.remove(observer);
      expect(observers.all, isNot(contains(observer)));
    });

    test('Should add multiple observers', () {
      final observer1 = Observer(() {});
      final observer2 = Observer(() {});
      final observer3 = Observer(() {});

      observers.add(observer1);
      observers.add(observer2);
      observers.add(observer3);

      expect(observers.all.length, 3);
      expect(observers.all, containsAll([observer1, observer2, observer3]));
    });

    test('Should remove specific observer without affecting others', () {
      final observer1 = Observer(() {});
      final observer2 = Observer(() {});
      final observer3 = Observer(() {});

      observers.add(observer1);
      observers.add(observer2);
      observers.add(observer3);

      observers.remove(observer2);

      expect(observers.all.length, 2);
      expect(observers.all, containsAll([observer1, observer3]));
      expect(observers.all, isNot(contains(observer2)));
    });
  });

  group('notify -', () {
    test('Should notify all observers when notify() is called', () {
      var callback1Called = false;
      var callback2Called = false;
      var callback3Called = false;

      final observer1 = Observer(() {
        callback1Called = true;
      });
      final observer2 = Observer(() {
        callback2Called = true;
      });
      final observer3 = Observer(() {
        callback3Called = true;
      });

      observers.add(observer1);
      observers.add(observer2);
      observers.add(observer3);

      observers.notify();

      expect(callback1Called, isTrue);
      expect(callback2Called, isTrue);
      expect(callback3Called, isTrue);
    });

    test('Should notify observers in the order they were added', () {
      final callOrder = <int>[];

      final observer1 = Observer(() {
        callOrder.add(1);
      });
      final observer2 = Observer(() {
        callOrder.add(2);
      });
      final observer3 = Observer(() {
        callOrder.add(3);
      });

      observers.add(observer1);
      observers.add(observer2);
      observers.add(observer3);

      observers.notify();

      expect(callOrder, equals([1, 2, 3]));
    });

    test('Should not notify observers when disallowNotify() is called', () {
      var callbackCalled = false;
      final observer = Observer(() {
        callbackCalled = true;
      });

      observers.add(observer);
      observers.disallowNotify();
      observers.notify();

      expect(callbackCalled, isFalse);
    });

    test('Should notify observers again after allowNotify() is called', () {
      var callbackCalled = false;
      final observer = Observer(() {
        callbackCalled = true;
      });

      observers.add(observer);
      observers.disallowNotify();
      observers.notify();
      expect(callbackCalled, isFalse);

      observers.allowNotify();
      observers.notify();
      expect(callbackCalled, isTrue);
    });
  });

  group('all getter -', () {
    test('Should return all non-internal observers', () {
      final regularObserver1 = Observer(() {});
      final regularObserver2 = Observer(() {});
      final internalObserver = InternalObserver(() {});

      observers.add(regularObserver1);
      observers.add(internalObserver);
      observers.add(regularObserver2);

      final allObservers = observers.all.toList();
      expect(allObservers.length, 2);
      expect(allObservers, containsAll([regularObserver1, regularObserver2]));
      expect(allObservers, isNot(contains(internalObserver)));
    });

    test('Should return empty iterable when only internal observers exist', () {
      final internalObserver1 = InternalObserver(() {});
      final internalObserver2 = InternalObserver(() {});

      observers.add(internalObserver1);
      observers.add(internalObserver2);

      expect(observers.all, isEmpty);
    });

    test('Should return all regular observers when mixed with internal observers', () {
      final regularObserver = Observer(() {});
      final internalObserver1 = InternalObserver(() {});
      final internalObserver2 = InternalObserver(() {});

      observers.add(internalObserver1);
      observers.add(regularObserver);
      observers.add(internalObserver2);

      expect(observers.all.length, 1);
      expect(observers.all, contains(regularObserver));
    });

    test('Should remove internal observer', () {
      var internalObserverCalled = 0;
      final internalObserver = InternalObserver(() {
        internalObserverCalled += 1;
      });

      observers.add(internalObserver);
      observers.notify();

      expect(internalObserverCalled, 1);
      observers.notify();
      expect(internalObserverCalled, 2);

      observers.remove(internalObserver);
      observers.notify();
      expect(internalObserverCalled, isNot(3));
      expect(internalObserverCalled, 2);
    });
  });

  group('hasObservers -', () {
    test('Should return false when no observers are added', () {
      expect(observers.hasObservers, isFalse);
    });

    test('Should return true when regular observer is added', () {
      final observer = Observer(() {});
      observers.add(observer);
      expect(observers.hasObservers, isTrue);
    });

    test('Should return false when only internal observers are added', () {
      final internalObserver = InternalObserver(() {});
      observers.add(internalObserver);
      expect(observers.hasObservers, isFalse);
    });

    test('Should return true when both regular and internal observers exist', () {
      final regularObserver = Observer(() {});
      final internalObserver = InternalObserver(() {});

      observers.add(internalObserver);
      observers.add(regularObserver);

      expect(observers.hasObservers, isTrue);
    });

    test('Should return false after removing all regular observers', () {
      final regularObserver = Observer(() {});
      observers.add(regularObserver);
      expect(observers.hasObservers, isTrue);

      observers.remove(regularObserver);
      expect(observers.hasObservers, isFalse);
    });
  });

  group('internal observers -', () {
    test('Should notify internal observers when notify() is called', () {
      var internalCallbackCalled = false;
      final internalObserver = InternalObserver(() {
        internalCallbackCalled = true;
      });

      observers.add(internalObserver);
      observers.notify();

      expect(internalCallbackCalled, isTrue);
    });

    test('Should notify both regular and internal observers', () {
      var regularCallbackCalled = false;
      var internalCallbackCalled = false;

      final regularObserver = Observer(() {
        regularCallbackCalled = true;
      });
      final internalObserver = InternalObserver(() {
        internalCallbackCalled = true;
      });

      observers.add(regularObserver);
      observers.add(internalObserver);

      observers.notify();

      expect(regularCallbackCalled, isTrue);
      expect(internalCallbackCalled, isTrue);
    });

    test('Internal observers should not appear in all getter', () {
      final regularObserver = Observer(() {});
      final internalObserver = InternalObserver(() {});

      observers.add(regularObserver);
      observers.add(internalObserver);

      final allObservers = observers.all.toList();
      expect(allObservers.length, 1);
      expect(allObservers, contains(regularObserver));
      expect(allObservers, isNot(contains(internalObserver)));
    });

    test('Should be able to remove internal observers directly', () {
      var callbackCalled = false;
      final internalObserver = InternalObserver(() {
        callbackCalled = true;
      });

      observers.add(internalObserver);
      observers.remove(internalObserver);
      observers.notify();

      expect(callbackCalled, isFalse);
    });

    test('Internal observers should not be notified when disallowNotify is called', () {
      var internalCallbackCalled = false;
      final internalObserver = InternalObserver(() {
        internalCallbackCalled = true;
      });

      observers.add(internalObserver);
      observers.disallowNotify();
      observers.notify();

      // Note: Based on the implementation, disallowNotify prevents ALL notifications
      // including internal ones. This test verifies the actual behavior.
      expect(internalCallbackCalled, isFalse);
    });
  });

  group('edge cases -', () {
    test('Should handle removing non-existent observer gracefully', () {
      final observer = Observer(() {});
      expect(() => observers.remove(observer), returnsNormally);
      expect(observers.all, isEmpty);
    });

    test('Should handle adding the same observer multiple times', () {
      final observer = Observer(() {});

      observers.add(observer);
      observers.add(observer);
      observers.add(observer);

      // List allows duplicates, so it should contain the observer multiple times
      expect(observers.all.length, 3);
      expect(observers.all, everyElement(equals(observer)));
    });

    test('Should handle notify() with no observers', () {
      expect(() => observers.notify(), returnsNormally);
    });
  });
}
