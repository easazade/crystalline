import 'dart:collection';

import 'package:crystalline/src/data.dart';

typedef _DataPredicate<T> = bool Function(
    List<Data<T>> value, Operation operation, DataError? error)?;

abstract class CollectionData<T> extends Data<List<Data<T>>>
    with ListMixin<Data<T>> {
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

  bool _notifyObserverIsAllowed = true;

  bool get availableWhenEmpty => true;

  @override
  void addObserver(void Function() observer) {
    super.addObserver(observer);
    items.forEach((item) => item.addObserver(observer));
  }

  @override
  void removeObserver(void Function() observer) {
    super.removeObserver(observer);
    items.forEach((item) => item.removeObserver(observer));
  }

  @override
  int get length => items.length;

  @override
  Data<T> operator [](int index) => items[index];

  @override
  void operator []=(int index, Data<T> value) {
    items[index] = value;
    _notifyObservers();
  }

  void modify(Iterable<Data<T>> Function(List<Data<T>> items) modifier) {
    _notifyObserverIsAllowed = false;
    final newItems = modifier(items);
    items.clear();
    items.addAll(newItems);
    _notifyObserverIsAllowed = true;
  }

  Future<void> modifyAsync(
      Future<Iterable<Data<T>>> Function(List<Data<T>> items) modifier) async {
    _notifyObserverIsAllowed = false;
    final newItems = await modifier(items);
    items.clear();
    items.addAll(newItems);
    _notifyObserverIsAllowed = true;
  }

  @override
  set length(int newLength) {
    items.length = length;
    _notifyObservers();
  }

  void _notifyObservers() {
    if (_notifyObserverIsAllowed)
      observers.forEach((observer) => observer.call());
  }
}

class ListData<T> extends CollectionData<T> {
  ListData(
    this.items, {
    this.isLoadingStrategy,
    this.hasErrorStrategy,
    this.isAvailableStrategy,
    this.isNotAvailableStrategy,
    this.isCreatingStrategy,
    this.isDeletingStrategy,
    this.isFetchingStrategy,
    this.isUpdatingStrategy,
  });

  @override
  final List<Data<T>> items;

  final _DataPredicate<T> isLoadingStrategy;
  final _DataPredicate<T> hasErrorStrategy;
  final _DataPredicate<T> isAvailableStrategy;
  final _DataPredicate<T> isNotAvailableStrategy;
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
  bool get isAvailable {
    return isAvailableStrategy?.call(value, operation, errorOrNull) ??
        super.isAvailable;
  }

  @override
  bool get isNotAvailable {
    return isNotAvailableStrategy?.call(value, operation, errorOrNull) ??
        super.isNotAvailable;
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
}
