import 'dart:async';

import 'package:crystalline/crystalline.dart';

abstract class Store extends Data<void> {
  Store() {
    unawaited(onInstantiate());
  }

  bool _initTriggered = false;

  final _initializationCompleter = Completer();

  Future<void> ensureInitialized() => _initializationCompleter.future;

  List<Data<Object?>> get states;

  Future<void> onInstantiate() async {}

  Future<void> init() async {}

  void onObserverAdded(Observer observer) {}

  void onObserverRemoved(Observer observer) {}

  void clear() {}

  void _triggerInit() {
    if (!_initTriggered) {
      _initTriggered = true;
      init().then((_) {
        _initializationCompleter.complete();
        publish();
      });
    }
  }

  late final _storeObservers = StoreObservers(this);

  @override
  StoreObservers get observers => _storeObservers;

  @override
  String? get name;

  void publish() {
    // setting forceNotify:true, since StoreObservers is disallowed notify by design.
    observers.notify(forceNotify: true);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('$runtimeType: ${CrystallineGlobalConfig.logger.generateToStringForData(this)}');

    if (states.isNotEmpty) {
      buffer.writeln();
    }

    for (final state in states) {
      buffer.writeln(state.toString());
    }

    return buffer.toString();
  }
}

class StoreObservers extends DataObservers {
  final Store _store;
  StoreObservers(this._store) : super(_store) {
    disallowNotify();
  }

  @override
  void add(Observer observer, {bool emitCurrent = false}) {
    super.add(observer);
    _store._triggerInit();
    _store.onObserverAdded(observer);
  }

  @override
  void remove(Observer observer) {
    super.remove(observer);
    _store.onObserverRemoved(observer);
    if (!hasObservers) {
      _store.clear();
    }
  }
}
