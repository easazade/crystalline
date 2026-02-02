import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/semantics/events.dart';
import 'package:crystalline/src/semantics/operation.dart';

typedef DataPredicate<T> = bool Function(List<Data<T>> value, Operation operation, Failure? failure)?;

class AddItemEvent<T> extends Event {
  AddItemEvent(this.newItem, this.items)
      : super(
          CrystallineGlobalConfig.logger.ellipsize(newItem.toString(), maxSize: 20),
        );

  final Data<T> newItem;
  final Iterable<Data<T>> items;
}

class RemoveItemEvent<T> extends Event {
  RemoveItemEvent(this.removedItem, this.items)
      : super(
          CrystallineGlobalConfig.logger.ellipsize(removedItem.toString(), maxSize: 20),
        );

  final Data<T> removedItem;
  final Iterable<Data<T>> items;
}

class ItemsUpdatedEvent<T> extends Event {
  ItemsUpdatedEvent(this.items) : super('${items.runtimeType} = ${items.length}');

  final Iterable<Data<T>> items;
}

abstract class CollectionData<T> extends Data<List<Data<T>>> with Iterable<Data<T>> {
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
    for (var item in items) {
      item.addObserver(observer);
    }
  }

  @override
  void removeObserver(void Function() observer) {
    super.removeObserver(observer);
    for (var e in items) {
      e.removeObserver(observer);
    }
  }

  @override
  Iterator<Data<T>> get iterator => items.iterator;

  @override
  int get length => items.length;

  Data<T> operator [](int index) => items[index];

  void operator []=(int index, Data<T> value) {
    items[index] = value;
    _addObserversToItem(value);
    dispatchEvent(AddItemEvent(value, items));
    dispatchEvent(ItemsUpdatedEvent(items));
    notifyObservers();
  }

  Data<T> removeAt(int index) {
    final removedItem = items.removeAt(index);
    _removeObserversFromItem(removedItem);
    dispatchEvent(RemoveItemEvent(removedItem, items));
    dispatchEvent(ItemsUpdatedEvent(items));
    notifyObservers();
    return removedItem;
  }

  void removeAll() {
    for (var e in items) {
      _removeObserversFromItem(e);
    }
    items.clear();
    dispatchEvent(ItemsUpdatedEvent(items));
    notifyObservers();
  }

  void add(Data<T> data) {
    items.add(data);
    _addObserversToItem(data);
    dispatchEvent(AddItemEvent(data, items));
    dispatchEvent(ItemsUpdatedEvent(items));
    notifyObservers();
  }

  void insert(int index, Data<T> data) {
    items.insert(index, data);
    _addObserversToItem(data);
    dispatchEvent(AddItemEvent(data, items));
    dispatchEvent(ItemsUpdatedEvent(items));
    notifyObservers();
  }

  void addAll(Iterable<Data<T>> list) {
    items.addAll(list);
    for (var item in list) {
      _addObserversToItem(item);
    }
    dispatchEvent(ItemsUpdatedEvent(items));
    notifyObservers();
  }

  void removeWhere(bool Function(Data<T> element) test) {
    for (var item in items.where(test)) {
      _removeObserversFromItem(item);
    }
    items.removeWhere(test);
    dispatchEvent(ItemsUpdatedEvent(items));
    notifyObservers();
  }

  void modifyItems(Iterable<Data<T>> Function(List<Data<T>> items) modifier) {
    disallowNotify();
    final oldItems = items.toList();
    final newItems = modifier(items).toList();
    for (var e in items) {
      _removeObserversFromItem(e);
    }
    items.clear();
    items.addAll(newItems);
    for (var e in items) {
      _addObserversToItem(e);
    }
    allowNotify();
    if (oldItems != items) {
      dispatchEvent(ItemsUpdatedEvent(items));
    }
    notifyObservers();
  }

  Future<void> modifyItemsAsync(Future<Iterable<Data<T>>> Function(List<Data<T>> items) modifier) async {
    disallowNotify();
    final oldItems = items.toList();
    final newItems = await modifier(items).then((e) => e.toList());
    for (var e in items) {
      _removeObserversFromItem(e);
    }
    items.clear();
    items.addAll(newItems);
    for (var e in items) {
      _addObserversToItem(e);
    }
    allowNotify();
    if (oldItems != items) {
      dispatchEvent(ItemsUpdatedEvent(items));
    }
    notifyObservers();
  }

  @override
  void modify(void Function(CollectionData<T> data) fn) {
    disallowNotify();
    final old = copy();
    fn(this);
    allowNotify();
    if (old.items != items) {
      dispatchEvent(ItemsUpdatedEvent(items));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old.failureOrNull != failureOrNull && failureOrNull != null) {
      dispatchEvent(FailureEvent(failure));
    }
    if (!ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      dispatchEvent(SideEffectsUpdatedEvent(sideEffects));
    }
    notifyObservers();
  }

  @override
  Future<void> modifyAsync(
    Future<void> Function(CollectionData<T> data) fn,
  ) async {
    disallowNotify();
    final old = copy();
    await fn(this);
    allowNotify();
    if (old.items != items) {
      dispatchEvent(ItemsUpdatedEvent(items));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old.failureOrNull != failureOrNull && failureOrNull != null) {
      dispatchEvent(FailureEvent(failure));
    }
    if (!ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      dispatchEvent(SideEffectsUpdatedEvent(sideEffects));
    }
    notifyObservers();
  }

  @override
  void updateFrom(Data<List<Data<T>>> data) {
    disallowNotify();
    final old = copy();
    for (var e in items) {
      _removeObserversFromItem(e);
    }
    items.clear();
    items.addAll(data.value.toList());
    for (var e in items) {
      _addObserversToItem(e);
    }
    operation = data.operation;
    failure = data.failureOrNull;
    removeAllSideEffects();
    addAllSideEffects(data.sideEffects);
    allowNotify();
    if (old.items != items) {
      dispatchEvent(ItemsUpdatedEvent(items));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old.failureOrNull != failureOrNull && failureOrNull != null) {
      dispatchEvent(FailureEvent(failure));
    }
    if (!ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      dispatchEvent(SideEffectsUpdatedEvent(sideEffects));
    }
    notifyObservers();
  }

  @override
  void reset() {
    modify((collection) {
      collection.removeAll();
      collection.operation = Operation.none;
      collection.failure = null;
      collection.removeAllSideEffects();
    });
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
        operation: operation,
        failure: failureOrNull,
        sideEffects: sideEffects.toList(),
      );

  @override
  bool operator ==(Object other) {
    if (other is! CollectionData<T>) return false;

    return runtimeType == other.runtimeType &&
        ListEquality<Data<T>>().equals(items, other.items) &&
        operation == other.operation &&
        failureOrNull == other.failureOrNull;
  }

  @override
  int get hashCode => items.hashCode + operation.hashCode + (failureOrNull?.hashCode ?? 1);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);
}

class ListData<T> extends CollectionData<T> {
  ListData(
    this.items, {
    Operation operation = Operation.none,
    Failure? failure,
    List<dynamic>? sideEffects,
    this.isAnyOperationStrategy,
    this.hasFailureStrategy,
    this.hasValueStrategy,
    this.hasNoValueStrategy,
    this.isCreatingStrategy,
    this.isDeletingStrategy,
    this.isReadingStrategy,
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

  final DataPredicate<T> isAnyOperationStrategy;
  final DataPredicate<T> hasFailureStrategy;
  final DataPredicate<T> hasValueStrategy;
  final DataPredicate<T> hasNoValueStrategy;
  final DataPredicate<T> isCreatingStrategy;
  final DataPredicate<T> isDeletingStrategy;
  final DataPredicate<T> isReadingStrategy;
  final DataPredicate<T> isUpdatingStrategy;
  final DataPredicate<T> hasCustomOperationStrategy;

  @override
  bool get isAnyOperation {
    return isAnyOperationStrategy?.call(value, operation, failureOrNull) ?? super.isAnyOperation;
  }

  @override
  bool get hasFailure {
    return hasFailureStrategy?.call(value, operation, failureOrNull) ?? super.hasFailure;
  }

  @override
  bool get hasValue {
    return hasValueStrategy?.call(value, operation, failureOrNull) ?? super.hasValue;
  }

  @override
  bool get hasNoValue {
    return hasNoValueStrategy?.call(value, operation, failureOrNull) ?? super.hasNoValue;
  }

  @override
  bool get isCreating {
    return isCreatingStrategy?.call(value, operation, failureOrNull) ?? super.isCreating;
  }

  @override
  bool get isDeleting {
    return isDeletingStrategy?.call(value, operation, failureOrNull) ?? super.isDeleting;
  }

  @override
  bool get isReading {
    return isReadingStrategy?.call(value, operation, failureOrNull) ?? super.isReading;
  }

  @override
  bool get isUpdating {
    return isUpdatingStrategy?.call(value, operation, failureOrNull) ?? super.isUpdating;
  }

  @override
  bool get hasCustomOperation {
    return hasCustomOperationStrategy?.call(value, operation, failureOrNull) ?? super.hasCustomOperation;
  }

  @override
  ListData<T> copy() => ListData(
        items.toList().map((data) => data.copy()).toList(),
        operation: operation,
        failure: failureOrNull,
        sideEffects: sideEffects.toList(),
        isAnyOperationStrategy: isAnyOperationStrategy,
        hasFailureStrategy: hasFailureStrategy,
        hasValueStrategy: hasValueStrategy,
        hasNoValueStrategy: hasNoValueStrategy,
        isCreatingStrategy: isCreatingStrategy,
        isDeletingStrategy: isDeletingStrategy,
        isReadingStrategy: isReadingStrategy,
        isUpdatingStrategy: isUpdatingStrategy,
        hasCustomOperationStrategy: hasCustomOperationStrategy,
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

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);
}
