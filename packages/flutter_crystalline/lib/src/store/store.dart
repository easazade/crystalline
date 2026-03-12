import 'dart:async';

import 'package:crystalline/crystalline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_crystalline/src/store/store_logger.dart';

abstract class Store extends Data<void> {
  Store() {
    disallowNotify();
    unawaited(onInstantiate());
  }

  bool _isInitializeTriggered = false;

  final _initializationCompleter = Completer();

  late final Listenable listenable = _StoreListenable(this);

  @protected
  late final log = StoreLogger(this);

  Future<void> ensureInitialized() => _initializationCompleter.future;

  List<Data<Object?>> get states;

  @protected
  Future<void> onInstantiate() async {}

  @protected
  Future<void> onInitialize() async {}

  @protected
  void onObserverAdded(Observer observer) {}

  @protected
  void onObserverRemoved(Observer observer) {}

  @protected
  void clear() {}

  void initialize() {
    if (!_isInitializeTriggered) {
      _isInitializeTriggered = true;
      onInitialize().then((_) {
        _initializationCompleter.complete();
      });
    }
  }

  late final _storeObservers = StoreObservers(this);

  @override
  StoreObservers get observers => _storeObservers;

  @override
  String? get name;

  @protected
  void publish() {
    // setting forceNotify:true, since StoreObservers is disallowed notify by design.
    streamController.add(true);
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

  @override
  bool operator ==(Object other) {
    if (other is! Store) return false;

    return other.runtimeType == runtimeType &&
        failureOrNull == other.failureOrNull &&
        operation == other.operation &&
        ListEquality().equals(sideEffects.all.toList(), other.sideEffects.all.toList()) &&
        ListEquality().equals(states, other.states);
  }

  @override
  int get hashCode =>
      (failureOrNull?.hashCode ?? 9) +
      sideEffects.all.hashCode +
      states.hashCode +
      operation.hashCode +
      runtimeType.hashCode;

  @override
  Stream<Store> get stream => streamController.stream.map((e) => this);
}

class _StoreListenable extends ChangeNotifier {
  _StoreListenable(this._store);

  final Store _store;
  StreamSubscription<Store>? _subscription;

  @override
  void addListener(VoidCallback listener) {
    final hadListeners = hasListeners;
    super.addListener(listener);
    if (!hadListeners) {
      _subscription = _store.stream.listen((_) => notifyListeners());
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _subscription?.cancel();
      _subscription = null;
    }
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
    _store.initialize();
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
