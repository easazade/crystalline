import 'dart:async';

import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class Store extends Data<void> with ChangeNotifier {
  Store() {
    unawaited(onInstantiate());
  }

  bool _initTriggered = false;

  final _initializationCompleter = Completer();

  Future<void> ensureInitialized() => _initializationCompleter.future;

  List<Data<Object?>> get states;

  Future<void> init() async {}

  Future<void> onInstantiate() async {}

  void _triggerInit() {
    if (!_initTriggered) {
      _initTriggered = true;
      init().then((_) {
        _initializationCompleter.complete();
      });
    }
  }

  late final _storeObservers = StoreObservers(this);

  @override
  StoreObservers get observers => _storeObservers;

  @override
  // ignore: unnecessary_overrides
  void addListener(void Function() listener) {
    _triggerInit();
    super.addListener(listener);
  }

  @override
  String? get name;

  void publish() => (this as ChangeNotifier).notifyListeners();

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
  StoreObservers(this._store) : super(_store);

  @override
  void add(Observer observer) {
    _store._triggerInit();
    super.add(observer);
  }
}
