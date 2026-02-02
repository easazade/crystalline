import 'package:crystalline/crystalline.dart';
import 'package:meta/meta.dart';

class DataObservers {
  final Data _data;
  DataObservers(this._data);

  var _allowedToNotify = true;

  final List<void Function()> _observers = [];

  Iterable<void Function()> get all => _observers.toList();

  void add(void Function() observer) => _observers.add(observer);

  void remove(void Function() observer) => _observers.remove(observer);

  bool get hasObservers => all.isNotEmpty;

  @mustCallSuper
  void notify() {
    final stateChangeLog = CrystallineGlobalConfig.logger.globalLogFilter(_data);
    if (stateChangeLog != null) {
      CrystallineGlobalConfig.logger.log(stateChangeLog);
    }
    if (_allowedToNotify) {
      for (final observer in all) {
        observer();
      }
    }
  }

  void clear() => _observers.clear();

  void allowNotify() => _allowedToNotify = true;

  void disallowNotify() => _allowedToNotify = false;
}

class CollectionDataObservers extends DataObservers {
  final CollectionData _collectionData;

  CollectionDataObservers(this._collectionData) : super(_collectionData);

  @override
  void add(void Function() observer) {
    super.add(observer);
    for (var item in _collectionData.items) {
      item.observers.add(observer);
    }
  }

  @override
  void remove(void Function() observer) {
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
  void add(void Function() observer) {
    if (_refreshData.hasNoValue) _refreshData.refresh(allowRetry: false);
    super.add(observer);
  }
}
