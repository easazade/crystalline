import 'package:crystalline/src/data.dart';

typedef _DataPredicate<T> = bool Function(
    List<Data<T>> value, Operation operation, DataError? error)?;

abstract class CollectionData<T> extends Data<List<Data<T>>>
    with Iterable<Data<T>> {
  bool _notifyObserverIsAllowed = true;

  List<Data<T>> get items;

  @override
  List<Data<T>> get value => items;

  @override
  set value(List<Data<T>>? value) {
    throw Exception(
      'You cannot change value of a $runtimeType directly. please use '
      'modify() or modifyAsync() instead.',
    );
  }

  @override
  void addObserver(void Function() observer) {
    super.addObserver(observer);
    items.forEach((item) => item.addObserver(observer));
  }

  @override
  void removeObserver(void Function() observer) {
    super.removeObserver(observer);
    items.forEach((e) => e.removeObserver(observer));
  }

  @override
  Iterator<Data<T>> get iterator => items.iterator;

  int get length => items.length;

  Data<T> operator [](int index) => items[index];

  void operator []=(int index, Data<T> value) {
    items[index] = value;
    _notifyObservers();
  }

  Data<T> removeAt(int index) {
    final removedItem = items.removeAt(index);
    _removeObserversFromItem(removedItem);
    _notifyObservers();
    return removedItem;
  }

  void removeAll() {
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    _notifyObservers();
  }

  void add(Data<T> data) {
    items.add(data);
    _addObserversToItem(data);
    _notifyObservers();
  }

  void insert(int index, Data<T> data) {
    items.insert(index, data);
    _addObserversToItem(data);
    _notifyObservers();
  }

  void addAll(Iterable<Data<T>> list) {
    items.addAll(list);
    for (var item in list) {
      _addObserversToItem(item);
    }
    _notifyObservers();
  }

  void removeWhere(bool Function(Data<T> element) test) {
    for (var item in items.where(test)) {
      _removeObserversFromItem(item);
    }
    items.removeWhere(test);
    _notifyObservers();
  }

  void modify(Iterable<Data<T>> Function(List<Data<T>> items) modifier) {
    _notifyObserverIsAllowed = false;
    final newItems = modifier(items);
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(newItems);
    items.forEach((e) => _addObserversToItem(e));
    _notifyObserverIsAllowed = true;
    _notifyObservers();
  }

  Future<void> modifyAsync(
      Future<Iterable<Data<T>>> Function(List<Data<T>> items) modifier) async {
    _notifyObserverIsAllowed = false;
    final newItems = await modifier(items);
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(newItems);
    items.forEach((e) => _addObserversToItem(e));
    _notifyObserverIsAllowed = true;
    _notifyObservers();
  }

  void _notifyObservers() {
    if (_notifyObserverIsAllowed)
      observers.forEach((observer) => observer.call());
  }

  void _removeObserversFromItem(Data<T> item) {
    for (var observer in observers) {
      item.removeObserver(observer);
    }
  }

  void _addObserversToItem(Data<T> item) {
    for (var observer in observers) {
      item.addObserver(observer);
    }
  }
}

class ListData<T> extends CollectionData<T> {
  ListData(
    this.items, {
    Operation operation = Operation.none,
    DataError? error,
    this.isLoadingStrategy,
    this.hasErrorStrategy,
    this.hasValueStrategy,
    this.hasNoValueStrategy,
    this.isCreatingStrategy,
    this.isDeletingStrategy,
    this.isFetchingStrategy,
    this.isUpdatingStrategy,
  }) {
    this.operation = operation;
    this.error = error;
  }

  @override
  final List<Data<T>> items;

  final _DataPredicate<T> isLoadingStrategy;
  final _DataPredicate<T> hasErrorStrategy;
  final _DataPredicate<T> hasValueStrategy;
  final _DataPredicate<T> hasNoValueStrategy;
  final _DataPredicate<T> isCreatingStrategy;
  final _DataPredicate<T> isDeletingStrategy;
  final _DataPredicate<T> isFetchingStrategy;
  final _DataPredicate<T> isUpdatingStrategy;

  @override
  bool get isLoading {
    return isLoadingStrategy?.call(value, operation, errorOrNull) ??
        super.isLoading;
  }

  @override
  bool get hasError {
    return hasErrorStrategy?.call(value, operation, errorOrNull) ??
        super.hasError;
  }

  @override
  bool get hasValue {
    return hasValueStrategy?.call(value, operation, errorOrNull) ??
        super.hasValue;
  }

  @override
  bool get hasNoValue {
    return hasNoValueStrategy?.call(value, operation, errorOrNull) ??
        super.hasNoValue;
  }

  @override
  bool get isCreating {
    return isCreatingStrategy?.call(value, operation, errorOrNull) ??
        super.isCreating;
  }

  @override
  bool get isDeleting {
    return isDeletingStrategy?.call(value, operation, errorOrNull) ??
        super.isDeleting;
  }

  @override
  bool get isFetching {
    return isFetchingStrategy?.call(value, operation, errorOrNull) ??
        super.isFetching;
  }

  @override
  bool get isUpdating {
    return isUpdatingStrategy?.call(value, operation, errorOrNull) ??
        super.isUpdating;
  }

  @override
  ListData<T> copy() => ListData(
        items.toList().map((data) => data.copy()).toList(),
        operation: this.operation,
        error: this.errorOrNull,
      );
}
