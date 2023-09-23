import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:collection/collection.dart';

typedef _DataPredicate<T> = bool Function(
    List<Data<T>> value, Operation operation, Failure? failure)?;

abstract class CollectionData<T> extends Data<List<Data<T>>>
    with Iterable<Data<T>> {
  List<Data<T>> get items;

  @override
  List<Data<T>> get value => items;

  @override
  bool get hasValue => value.isNotEmpty;

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
    disallowNotify();
    final newItems = modifier(items).toList();
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(newItems);
    items.forEach((e) => _addObserversToItem(e));
    allowNotify();
    notifyObservers();
  }

  Future<void> modifyItemsAsync(
      Future<Iterable<Data<T>>> Function(List<Data<T>> items) modifier) async {
    disallowNotify();
    final newItems = await modifier(items).then((e) => e.toList());
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(newItems);
    items.forEach((e) => _addObserversToItem(e));
    allowNotify();
    notifyObservers();
  }

  @override
  void modify(void Function(CollectionData<T> data) fn) {
    super.modify((data) => fn(data as CollectionData<T>));
  }

  @override
  void updateFrom(ReadableData<List<Data<T>>> data) {
    disallowNotify();
    items.forEach((e) => _removeObserversFromItem(e));
    items.clear();
    items.addAll(data.value.toList());
    items.forEach((e) => _addObserversToItem(e));
    operation = data.operation;
    failure = data.failureOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects);
    allowNotify();
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
        failure: this.failureOrNull,
      );

  @override
  bool operator ==(Object other) {
    if (other is! CollectionData<T>) return false;

    return runtimeType == other.runtimeType &&
        ListEquality<Data<T>>().equals(items, other.items) &&
        operation == other.operation &&
        failureOrNull == other.failureOrNull;
  }
}

class ListData<T> extends CollectionData<T> {
  ListData(
    this.items, {
    Operation operation = Operation.none,
    Failure? failure,
    List<dynamic>? sideEffects,
    this.isOperatingStrategy,
    this.hasFailureStrategy,
    this.hasValueStrategy,
    this.hasNoValueStrategy,
    this.isCreatingStrategy,
    this.isDeletingStrategy,
    this.isFetchingStrategy,
    this.isUpdatingStrategy,
    this.hasCustomOperationStrategy,
  }) {
    this.operation = operation;
    this.failure = failure;
    if (sideEffects != null) {
      addAllSideEffects(sideEffects);
    }
  }

  @override
  final List<Data<T>> items;

  final _DataPredicate<T> isOperatingStrategy;
  final _DataPredicate<T> hasFailureStrategy;
  final _DataPredicate<T> hasValueStrategy;
  final _DataPredicate<T> hasNoValueStrategy;
  final _DataPredicate<T> isCreatingStrategy;
  final _DataPredicate<T> isDeletingStrategy;
  final _DataPredicate<T> isFetchingStrategy;
  final _DataPredicate<T> isUpdatingStrategy;
  final _DataPredicate<T> hasCustomOperationStrategy;

  @override
  bool get isOperating {
    return isOperatingStrategy?.call(value, operation, failureOrNull) ??
        super.isOperating;
  }

  @override
  bool get hasFailure {
    return hasFailureStrategy?.call(value, operation, failureOrNull) ??
        super.hasFailure;
  }

  @override
  bool get hasValue {
    return hasValueStrategy?.call(value, operation, failureOrNull) ??
        super.hasValue;
  }

  @override
  bool get hasNoValue {
    return hasNoValueStrategy?.call(value, operation, failureOrNull) ??
        super.hasNoValue;
  }

  @override
  bool get isCreating {
    return isCreatingStrategy?.call(value, operation, failureOrNull) ??
        super.isCreating;
  }

  @override
  bool get isDeleting {
    return isDeletingStrategy?.call(value, operation, failureOrNull) ??
        super.isDeleting;
  }

  @override
  bool get isFetching {
    return isFetchingStrategy?.call(value, operation, failureOrNull) ??
        super.isFetching;
  }

  @override
  bool get isUpdating {
    return isUpdatingStrategy?.call(value, operation, failureOrNull) ??
        super.isUpdating;
  }

  @override
  bool get hasCustomOperation {
    return hasCustomOperationStrategy?.call(value, operation, failureOrNull) ??
        super.hasCustomOperation;
  }

  @override
  ListData<T> copy() => ListData(
        items.toList().map((data) => data.copy()).toList(),
        operation: this.operation,
        failure: this.failureOrNull,
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
