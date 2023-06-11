import 'package:crystalline/src/exceptions.dart';

class Operation {
  static const Operation loading = Operation('loading');
  static const Operation update = Operation('update');
  static const Operation delete = Operation('delete');
  static const Operation fetch = Operation('fetch');
  static const Operation create = Operation('create');
  static const Operation none = Operation('none');

  static final defaultOperations = [
    loading,
    update,
    delete,
    fetch,
    create,
    none,
  ];

  final String name;

  const Operation(this.name);

  bool get isCustom => !defaultOperations.contains(this);
}

abstract class ReadableData<T> {
  T get value;

  T? get valueOrNull;

  DataError get error;

  DataError? get errorOrNull;

  Operation get operation;

  DataError get consumeError;

  bool get hasValue;

  bool get hasNoValue;

  bool get isLoading;

  bool get isUpdating;

  bool get isDeleting;

  bool get isFetching;

  bool get isCreating;

  bool get hasCustomOperation;

  bool get hasError;

  bool valueEqualsTo(T? another);
}

abstract class EditableData<T> {
  void set value(T? value);

  void set operation(Operation operation);

  void set error(DataError? error);
}

abstract class ObservableData<T> {
  void addObserver(void Function() observer);

  void removeObserver(void Function() observer);

  bool get hasObservers;
}

class DataError {
  const DataError(this.message, this.exception);

  final String message;

  final Exception exception;

  @override
  String toString() => '${super.toString()}\n$message\n';
}

class Data<T> implements ReadableData<T>, EditableData<T>, ObservableData<T> {
  T? _value;
  DataError? _error;
  Operation _operation;

  final List<void Function()> observers = [];

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

  T? get valueOrNull => _value;

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
  DataError? get errorOrNull => _error;

  @override
  bool get hasError => _error != null;

  @override
  bool get hasValue => _value != null;

  @override
  bool get hasNoValue => !hasValue;

  @override
  bool get isCreating => _operation == Operation.create;

  @override
  bool get isDeleting => _operation == Operation.delete;

  @override
  bool get isFetching => _operation == Operation.fetch;

  @override
  bool get isUpdating => _operation == Operation.update;

  @override
  bool get hasCustomOperation => _operation.isCustom;

  @override
  bool get isLoading =>
      _operation == Operation.loading ||
      isUpdating ||
      isFetching ||
      isDeleting ||
      isCreating;

  @override
  bool valueEqualsTo(T? otherValue) {
    if (hasValue) {
      return _value == otherValue;
    } else if (otherValue == null && this.hasNoValue) {
      return true;
    }

    return false;
  }

  @override
  void set error(DataError? error) {
    _error = error;
    if (observers.isNotEmpty) {
      observers.forEach((observer) => observer());
    }
  }

  @override
  void set operation(Operation operation) {
    _operation = operation;
    if (observers.isNotEmpty) {
      observers.forEach((observer) => observer());
    }
  }

  Operation get operation => _operation;

  @override
  set value(T? value) {
    _value = value;
    if (observers.isNotEmpty) {
      observers.forEach((observer) => observer());
    }
  }

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() =>
      Data<T>(value: _value, error: _error, operation: _operation);

  @override
  String toString() =>
      '$runtimeType - operation: $_operation - error: $_error - value : $_value';

  @override
  bool operator ==(Object other) {
    if (other is! Data<T>) return false;

    return other.runtimeType == runtimeType &&
        _error == other._error &&
        _value == other._value &&
        _operation == other._operation;
  }

  @override
  void addObserver(void Function() observer) {
    observers.add(observer);
  }

  @override
  void removeObserver(void Function() observer) {
    observers.remove(observer);
  }

  @override
  bool get hasObservers => observers.isNotEmpty;
}
