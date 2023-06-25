import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:meta/meta.dart';

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

  @override
  String toString() => 'Operation.$name';
}

abstract class ReadableData<T> {
  T get value;

  T? get valueOrNull;

  Failure get error;

  Failure? get errorOrNull;

  Operation get operation;

  Failure get consumeError;

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

  void set error(Failure? error);

  void modify(void Function(Data<T> data) fn);

  Future<void> modifyAsync(Future<void> Function(Data<T> data) fn);

  @mustCallSuper
  void allowNotifyObservers();

  @mustCallSuper
  void disallowNotifyObservers();

  @mustCallSuper
  void notifyObservers();

  void updateFrom(Data<T> data);
}

abstract class ObservableData<T> {
  void addObserver(void Function() observer);

  void removeObserver(void Function() observer);

  bool get hasObservers;
}

abstract class UnModifiableData<T>
    implements ReadableData<T>, ObservableData<T> {}

class Data<T> implements UnModifiableData<T>, EditableData<T> {
  T? _value;
  Failure? _error;
  Operation _operation;

  bool _allowNotifyObservers = true;

  final List<void Function()> observers = [];

  Data({T? value, Failure? error, Operation operation = Operation.none})
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
  Failure get consumeError {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    Failure consumedErrorValue = _error!;
    _error = null;
    return consumedErrorValue;
  }

  @override
  Failure get error {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    return _error!;
  }

  @override
  Failure? get errorOrNull => _error;

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
  void set error(Failure? error) {
    _error = error;
    notifyObservers();
  }

  @override
  void set operation(Operation operation) {
    _operation = operation;
    notifyObservers();
  }

  Operation get operation => _operation;

  @override
  set value(T? value) {
    _value = value;
    notifyObservers();
  }

  @override
  void modify(void Function(Data<T> data) fn) {
    disallowNotifyObservers();
    fn(this);
    allowNotifyObservers();
    notifyObservers();
  }

  @override
  Future<void> modifyAsync(Future<void> Function(Data<T> data) fn) async {
    disallowNotifyObservers();
    await fn(this);
    allowNotifyObservers();
    notifyObservers();
  }

  @override
  void updateFrom(Data<T> data) {
    disallowNotifyObservers();
    value = data.valueOrNull;
    operation = data.operation;
    error = data.errorOrNull;
    allowNotifyObservers();
    notifyObservers();
  }

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() =>
      Data<T>(value: _value, error: _error, operation: _operation);

  @override
  String toString() =>
      '{$runtimeType = $_operation | $_value${_error != null ? " | error: $error" : ""}}';

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

  @override
  void allowNotifyObservers() {
    _allowNotifyObservers = true;
  }

  @override
  void disallowNotifyObservers() {
    _allowNotifyObservers = false;
  }

  @override
  void notifyObservers() {
    if (_allowNotifyObservers) observers.forEach((observer) => observer());
  }
}
