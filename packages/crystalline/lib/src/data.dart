import 'package:crystalline/src/exceptions.dart';

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
