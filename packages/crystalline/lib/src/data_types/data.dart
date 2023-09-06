import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:crystalline/src/utils.dart';
import 'package:meta/meta.dart';

class Operation {
  static const Operation operating = Operation('operating');
  static const Operation update = Operation('update');
  static const Operation delete = Operation('delete');
  static const Operation fetch = Operation('fetch');
  static const Operation create = Operation('create');
  static const Operation none = Operation('none');

  static final defaultOperations = [
    operating,
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

class Event {
  Event(this.name);

  final String name;
}

abstract class ReadableData<T> {
  T get value;

  T? get valueOrNull;

  Failure get error;

  Failure? get errorOrNull;

  Operation get operation;

  Failure get consumeError;

  List<dynamic> get sideEffects;

  bool get hasSideEffects;

  bool get hasValue;

  bool get hasNoValue;

  bool get isOperating;

  bool get isUpdating;

  bool get isDeleting;

  bool get isFetching;

  bool get isCreating;

  bool get hasCustomOperation;

  bool get hasError;

  bool valueEqualsTo(T? another);
}

abstract class ModifiableData<T> {
  void set value(T? value);

  void set operation(Operation operation);

  void set error(Failure? error);

  void addSideEffect(dynamic sideEffect);

  void addAllSideEffects(Iterable<dynamic> sideEffect);

  void removeSideEffect(dynamic sideEffect);

  void clearAllSideEffects();

  void modify(void Function(Data<T> data) fn);

  Future<void> modifyAsync(Future<void> Function(Data<T> data) fn);

  @mustCallSuper
  void allowNotifyObservers();

  @mustCallSuper
  void disallowNotifyObservers();

  @mustCallSuper
  void notifyObservers();

  void updateFrom(ReadableData<T> data);

  void dispatchEvent(Event event);
}

abstract class ObservableData<T> {
  void addObserver(void Function() observer);

  void removeObserver(void Function() observer);

  bool get hasObservers;

  void addEventListener(bool Function() listener);

  void removeEventListener(bool Function() listener);
}

abstract class UnModifiableData<T>
    implements ReadableData<T>, ObservableData<T> {}

class Data<T> implements UnModifiableData<T>, ModifiableData<T> {
  T? _value;
  Failure? _error;
  Operation _operation;

  bool _allowedToNotifyObservers = true;

  final List<void Function()> observers = [];
  final List<bool Function()> eventListeners = [];
  final List<dynamic> _sideEffects;

  Data({
    T? value,
    Failure? error,
    Operation operation = Operation.none,
    List<dynamic>? sideEffects,
  })  : _value = value,
        _error = error,
        _sideEffects = sideEffects ?? [],
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
      throw ErrorIsNullException();
    }
    Failure consumedErrorValue = _error!;
    _error = null;
    return consumedErrorValue;
  }

  @override
  Failure get error {
    if (_error == null) {
      throw ErrorIsNullException();
    }
    return _error!;
  }

  @override
  List<dynamic> get sideEffects => _sideEffects;

  @override
  void addSideEffect(dynamic sideEffect) {
    _sideEffects.add(sideEffect);
    notifyObservers();
  }

  @override
  void addAllSideEffects(Iterable<dynamic> sideEffects) {
    _sideEffects.addAll(sideEffects);
    notifyObservers();
  }

  @override
  void removeSideEffect(dynamic sideEffect) {
    _sideEffects.remove(sideEffect);
    notifyObservers();
  }

  @override
  void clearAllSideEffects() {
    _sideEffects.clear();
    notifyObservers();
  }

  @override
  bool get hasSideEffects => _sideEffects.isNotEmpty;

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
  bool get isOperating => _operation != Operation.none;

  @override
  bool valueEqualsTo(T? otherValue) => _value == otherValue;

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
  void updateFrom(ReadableData<T> data) {
    disallowNotifyObservers();
    value = data.valueOrNull;
    operation = data.operation;
    error = data.errorOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects);
    allowNotifyObservers();
    notifyObservers();
  }

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() =>
      Data<T>(value: _value, error: _error, operation: _operation);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('{ ');
    buffer.write('$runtimeType = ');
    if (hasError) {
      buffer.write("error: ${inRed('<')}");
      if (_error?.id != null) {
        buffer.write(inRed('id: ${error.id} - '));
      }
      if (_error?.cause != null) {
        buffer.write(inRed('cause: ${error.cause} - '));
      }
      buffer.write('${inRed("${error.message}> ")}| ');
    }

    if (operation == Operation.none) {
      buffer.write('operation: ${operation.name}');
    } else {
      buffer.write('operation: ${inBlinking(inMagenta(operation.name))}');
    }

    if (hasValue) {
      buffer.write(' | value: ${inGreen(_value)}');
    } else {
      buffer.write(' | value: ${_value}');
    }

    buffer.writeln(' }');

    if (_error != null) {
      buffer.write('$error');
    }

    return buffer.toString();
  }

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
    _allowedToNotifyObservers = true;
  }

  @override
  void disallowNotifyObservers() {
    _allowedToNotifyObservers = false;
  }

  @override
  void notifyObservers() {
    if (_allowedToNotifyObservers) observers.forEach((observer) => observer());
  }

  @override
  void addEventListener(bool Function() listener) {
    eventListeners.add(listener);
  }

  @override
  void dispatchEvent(Event event) {
    if (_allowedToNotifyObservers) {
      for (var callback in eventListeners) {
        final eventConsumed = callback();
        if (eventConsumed) {
          break;
        }
      }
    }
  }

  @override
  void removeEventListener(bool Function() listener) {
    eventListeners.remove(listener);
  }
}
