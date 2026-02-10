import 'package:crystalline/crystalline.dart';
import 'package:crystalline/src/internal/internal.dart';
import 'package:meta/meta.dart';

class Observer {
  Observer(this.callback);

  void Function() callback;
}

class DataObservers {
  final Data _data;
  DataObservers(this._data);

  var _allowedToNotify = true;

  final List<Observer> _observers = [];

  Iterable<Observer> get all => _observers.toList().where((observer) => observer is! Internal);

  void add(Observer observer, {bool emitCurrent = false}) {
    _observers.add(observer);
    if (emitCurrent) {
      observer.callback();
    }
  }

  void remove(Observer observer) => _observers.remove(observer);

  bool get hasObservers => all.isNotEmpty;

  @mustCallSuper
  void notify({bool forceNotify = false}) {
    final stateChangeLog = CrystallineGlobalConfig.logger.globalLogFilter(_data);
    if (stateChangeLog != null) {
      CrystallineGlobalConfig.logger.log(stateChangeLog);
    }
    if (_allowedToNotify || forceNotify) {
      for (final observer in _observers) {
        observer.callback();
      }
    }
  }

  // void clear() {
  // _observers.removeWhere((observer) => observer is! Internal);
  // }

  void allowNotify() => _allowedToNotify = true;

  void disallowNotify() => _allowedToNotify = false;
}

class CollectionDataObservers extends DataObservers {
  final CollectionData _collectionData;

  CollectionDataObservers(this._collectionData) : super(_collectionData);

  @override
  void add(Observer observer, {bool emitCurrent = false}) {
    super.add(observer);
    for (var item in _collectionData.items) {
      item.observers.add(observer);
    }
  }

  @override
  void remove(Observer observer) {
    super.remove(observer);
    for (var e in _collectionData.items) {
      e.observers.remove(observer);
    }
  }
}

class RefreshDataObservers extends DataObservers {
  final RefreshData _refreshData;

  RefreshDataObservers(this._refreshData) : super(_refreshData);

  @override
  void add(Observer observer, {bool emitCurrent = false}) {
    if (_refreshData.hasNoValue) _refreshData.refresh(allowRetry: false);
    super.add(observer);
  }
}
