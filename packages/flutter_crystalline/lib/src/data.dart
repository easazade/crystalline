import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_crystalline/src/builders.dart';
import 'package:flutter_crystalline/src/exceptions.dart';
import 'package:flutter_crystalline/src/store_consumer.dart';

enum Operation {
  loading(1),
  update(2),
  delete(3),
  fetch(4),
  create(5),
  none(6);

  final int id;

  const Operation(this.id);

  factory Operation.fromId(int id) => values.firstWhere((e) => e.id == id);
}

abstract class ReadableData<T> {
  T get value;

  DataError get error;

  DataError get consumeError;

  bool get isAvailable;

  bool get isNotAvailable;

  bool get isLoading;

  bool get isUpdating;

  bool get isDeleting;

  bool get isFetching;

  bool get isCreating;

  bool get hasError;

  bool valueEqualsTo(T? another);
}

class BuildableData<T> extends Data<T> implements ReadableData<T>, EditableData<T> {
  BuildableData({super.value, super.error, super.operation});

  Widget build(final DataWidgetBuilder<T> builder) => DataBuilder<T>(data: this, builder: builder);

  Widget buildWhen({
    required DataWidgetBuilder<T> onAvailable,
    DataWidgetBuilder<T>? onNotAvailable,
    DataWidgetBuilder<T>? onLoading,
    DataWidgetBuilder<T>? onCreate,
    DataWidgetBuilder<T>? onDelete,
    DataWidgetBuilder<T>? onFetch,
    DataWidgetBuilder<T>? onUpdate,
    DataWidgetBuilder<T>? onError,
    DataWidgetBuilder<T>? orElse,
  }) =>
      WhenDataBuilder<T>(
        data: this,
        onAvailable: onAvailable,
        onNotAvailable: onNotAvailable,
        onLoading: onLoading,
        onCreate: onCreate,
        onDelete: onDelete,
        onFetch: onFetch,
        onUpdate: onUpdate,
        onError: onError,
        orElse: orElse,
      );
}

abstract class EditableData<T> {
  void set value(T? value);

  void set operation(Operation operation);

  void set error(DataError? error);
}

class DataError {
  const DataError(this.message, this.exception);

  final String message;

  final Exception exception;

  @override
  String toString() {
    return '${super.toString()}\n$message\n';
  }
}

class Data<T> implements ReadableData<T>, EditableData<T> {
  T? _value;
  DataError? _error;
  Operation _operation;

  // Data._(this._value, this._error, this._operation);

  Data({T? value, DataError? error, Operation operation = Operation.none})
      : _value = value,
        _error = error,
        _operation = operation;

  @override
  T get value {
    if (_value == null) {
      throw ValueNotAvailableException();
    }
    return _value!;
  }

  @override
  DataError get consumeError {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    DataError consumedErrorValue = _error!;
    _error = null;
    return consumedErrorValue;
  }

  @override
  DataError get error {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    return _error!;
  }

  @override
  bool get hasError => _error != null;

  @override
  bool get isAvailable => _value != null;

  @override
  bool get isNotAvailable => !isAvailable;

  @override
  bool get isCreating => _operation == Operation.create;

  @override
  bool get isDeleting => _operation == Operation.delete;

  @override
  bool get isFetching => _operation == Operation.fetch;

  @override
  bool get isUpdating => _operation == Operation.update;

  @override
  bool get isLoading => _operation == Operation.loading || isUpdating || isFetching || isDeleting || isCreating;

  @override
  bool valueEqualsTo(T? otherValue) {
    if (isAvailable) {
      return _value == otherValue;
    } else if (otherValue == null && isNotAvailable) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void set error(DataError? error) => _error = error;

  @override
  void set operation(Operation operation) => _operation = operation;

  @override
  set value(T? value) => _value = value;

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() => Data<T>(value: _value, error: _error, operation: _operation);

  @override
  String toString() => '$runtimeType - operation: $_operation - error: $_error - value : $_value';

  @override
  bool operator ==(Object other) {
    if (other is! Data<T>) return false;

    return other.runtimeType == runtimeType &&
        _error == other._error &&
        _value == other._value &&
        _operation == other._operation;
  }
}

abstract class Store<T extends BaseStore> extends BaseStore with EquatableMixin implements ReadableData<T> {
  DataError? _error;
  Operation _operation = Operation.none;

  @override
  T get value => this as T;

  @override
  DataError get consumeError {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    DataError consumedErrorValue = _error!;
    _error = null;
    return consumedErrorValue;
  }

  @override
  DataError get error {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    return _error!;
  }

  @override
  bool get hasError => _error != null;

  @override
  bool get isAvailable;

  @override
  List<Object?> get props;

  @override
  bool get isNotAvailable => !isAvailable;

  @override
  bool get isCreating => _operation == Operation.create;

  @override
  bool get isDeleting => _operation == Operation.delete;

  @override
  bool get isFetching => _operation == Operation.fetch;

  @override
  bool get isUpdating => _operation == Operation.update;

  @override
  bool get isLoading => _operation != Operation.none;

  @override
  bool valueEqualsTo(T? otherValue) => this == otherValue;

  void setStoreError(DataError? error) {
    _error = error;
  }

  void setStoreOperation(Operation operation) {
    _operation = operation;
  }

  Widget consume({
    required StoreWidgetBuilder<T> builder,
    final void Function(BuildContext context, T store)? listener,
  }) {
    return StoreConsumer(
      listener: listener,
      store: this as T,
      builder: builder,
    );
  }

  Widget consumeWhen({
    required StoreWidgetBuilder<T> onAvailable,
    void Function(BuildContext context, T store)? listener,
    StoreWidgetBuilder<T>? onNotAvailable,
    StoreWidgetBuilder<T>? onLoading,
    StoreWidgetBuilder<T>? onCreate,
    StoreWidgetBuilder<T>? onDelete,
    StoreWidgetBuilder<T>? onFetch,
    StoreWidgetBuilder<T>? onUpdate,
    StoreWidgetBuilder<T>? onError,
    StoreWidgetBuilder<T>? orElse,
  }) {
    return StoreConsumer(
      store: this as T,
      listener: listener,
      builder: (context, store) {
        return WhenStoreBuilder<T>(
          readableData: this,
          value: this as T,
          onAvailable: onAvailable,
          onNotAvailable: onNotAvailable,
          onLoading: onLoading,
          onCreate: onCreate,
          onDelete: onDelete,
          onFetch: onFetch,
          onUpdate: onUpdate,
          onError: onError,
          orElse: orElse,
        );
      },
    );
  }

  @override
  String toString() => '$runtimeType : operation: $_operation - error: $_error';
}

class BaseStore extends ChangeNotifier {
  final storeId = StoreId();
  void updateStore() => notifyListeners();
}

/// an object that only equals to itslef just like Flutter UniqueKey()
class StoreId {
  @override
  String toString() => '[#${_shortHash(this)}]';
}

String _shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}
