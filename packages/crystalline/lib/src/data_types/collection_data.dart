import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:collection/collection.dart';

typedef _DataPredicate<T> = bool Function(
    List<Data<T>> value, Operation operation, Failure? error)?;

abstract class CollectionData<T> extends Data<List<Data<T>>>
    with Iterable<Data<T>> {
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
    notifyObservers();
  }

  Data<T> removeAt(int index) {
    final removedItem = items.removeAt(index);
    _removeObserversFromItem(removedItem);
    notifyObservers();
    return removedItem;
  }

  void removeAll() {
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    notifyObservers();
  }

  void add(Data<T> data) {
    items.add(data);
    _addObserversToItem(data);
    notifyObservers();
  }

  void insert(int index, Data<T> data) {
    items.insert(index, data);
    _addObserversToItem(data);
    notifyObservers();
  }

  void addAll(Iterable<Data<T>> list) {
    items.addAll(list);
    for (var item in list) {
      _addObserversToItem(item);
    }
    notifyObservers();
  }

  void removeWhere(bool Function(Data<T> element) test) {
    for (var item in items.where(test)) {
      _removeObserversFromItem(item);
    }
    items.removeWhere(test);
    notifyObservers();
  }

  void modifyItems(Iterable<Data<T>> Function(List<Data<T>> items) modifier) {
    disallowNotifyObservers();
    final newItems = modifier(items).toList();
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(newItems);
    items.forEach((e) => _addObserversToItem(e));
    allowNotifyObservers();
    notifyObservers();
  }

  Future<void> modifyItemsAsync(
      Future<Iterable<Data<T>>> Function(List<Data<T>> items) modifier) async {
    disallowNotifyObservers();
    final newItems = await modifier(items).then((e) => e.toList());
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(newItems);
    items.forEach((e) => _addObserversToItem(e));
    allowNotifyObservers();
    notifyObservers();
  }

  @override
  void modify(void Function(CollectionData<T> data) fn) {
    super.modify((data) => fn(data as CollectionData<T>));
  }

  @override
  void updateFrom(ReadableData<List<Data<T>>> data) {
    if (data is! CollectionData<T>) {
      throw CannotUpdateFromTypeException(this, data);
    }
    disallowNotifyObservers();
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(data.items.toList());
    items.forEach((e) => _addObserversToItem(e));
    operation = data.operation;
    error = data.errorOrNull;
    allowNotifyObservers();
    notifyObservers();
  }

  @override
  Future<void> modifyAsync(
    Future<void> Function(CollectionData<T> data) fn,
  ) {
    return super.modifyAsync((data) => fn(data as CollectionData<T>));
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

  @override
  CollectionData<T> copy() => ListData(
        items.toList().map((data) => data.copy()).toList(),
        operation: this.operation,
        error: this.errorOrNull,
      );

  @override
  bool operator ==(Object other) {
    if (other is! CollectionData<T>) return false;

    return runtimeType == other.runtimeType &&
        ListEquality<Data<T>>().equals(items, other.items) &&
        operation == other.operation &&
        errorOrNull == other.errorOrNull;
  }
}

class ListData<T> extends CollectionData<T> {
  ListData(
    this.items, {
    Operation operation = Operation.none,
    Failure? error,
    List<dynamic>? sideEffects,
    this.isLoadingStrategy,
    this.hasErrorStrategy,
    this.hasValueStrategy,
    this.hasNoValueStrategy,
    this.isCreatingStrategy,
    this.isDeletingStrategy,
    this.isFetchingStrategy,
    this.isUpdatingStrategy,
    this.hasCustomOperationStrategy,
  }) {
    this.operation = operation;
    this.error = error;
    if (sideEffects != null) {
      sideEffects.addAll(sideEffects);
    }
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
  final _DataPredicate<T> hasCustomOperationStrategy;

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
  bool get hasCustomOperation {
    return hasCustomOperationStrategy?.call(value, operation, errorOrNull) ??
        super.hasCustomOperation;
  }

  @override
  ListData<T> copy() => ListData(
        items.toList().map((data) => data.copy()).toList(),
        operation: this.operation,
        error: this.errorOrNull,
      );

  @override
  void modify(void Function(ListData<T> data) fn) {
    super.modify((data) => fn(data as ListData<T>));
  }

  @override
  Future<void> modifyAsync(
    Future<void> Function(ListData<T> data) fn,
  ) {
    return super.modifyAsync((data) => fn(data as ListData<T>));
  }
}
