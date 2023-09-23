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
  const Event(this.name);

  final String name;
}

class OperationEvent extends Event {
  OperationEvent(this.operation) : super(operation.name);

  final Operation operation;
}

class ValueEvent<T> extends Event {
  ValueEvent(this.value) : super(ellipsize(value.toString(), maxSize: 20));

  final T value;
}

class FailureEvent extends Event {
  FailureEvent(this.failure) : super(ellipsize(failure.message, maxSize: 20));

  final Failure failure;
}

class SideEffectsUpdated extends Event {
  final List<dynamic> sideEffects;

  SideEffectsUpdated(this.sideEffects)
      : super('sideEffects: ${sideEffects.length}');
}

class AddSideEffectEvent extends Event {
  final dynamic newSideEffect;
  final List<dynamic> sideEffects;

  AddSideEffectEvent({required this.newSideEffect, required this.sideEffects})
      : super((newSideEffect.toString().length > 20)
            ? '${newSideEffect.toString().substring(0, 20)}...'
            : newSideEffect.toString());
}

class RemoveSideEffectEvent extends Event {
  final dynamic removedSideEffect;
  final List<dynamic> sideEffects;

  RemoveSideEffectEvent(
      {required this.removedSideEffect, required this.sideEffects})
      : super((removedSideEffect.toString().length > 20)
            ? '${removedSideEffect.toString().substring(0, 20)}...'
            : removedSideEffect.toString());
}

abstract class ReadableData<T> {
  T get value;

  T? get valueOrNull;

  Failure get failure;

  Failure? get failureOrNull;

  Operation get operation;

  Failure get consumeFailure;

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

  bool get hasFailure;

  bool valueEqualsTo(T? another);
}

abstract class ModifiableData<T> {
  void set value(T? value);

  void set operation(Operation operation);

  void set failure(Failure? failure);

  void addSideEffect(dynamic sideEffect);

  void addAllSideEffects(Iterable<dynamic> sideEffect);

  void removeSideEffect(dynamic sideEffect);

  void clearAllSideEffects();

  void modify(void Function(Data<T> data) fn);

  Future<void> modifyAsync(Future<void> Function(Data<T> data) fn);

  @mustCallSuper
  void allowNotify();

  @mustCallSuper
  void disallowNotify();

  @mustCallSuper
  void notifyObservers();

  void updateFrom(ReadableData<T> data);

  void dispatchEvent(Event event);
}

abstract class ObservableData<T> {
  void addObserver(void Function() observer);

  void removeObserver(void Function() observer);

  bool get hasObservers;

  bool get hasEventListeners;

  void addEventListener(bool Function(Event event) listener);

  void removeEventListener(bool Function(Event event) listener);
}

abstract class UnModifiableData<T>
    implements ReadableData<T>, ObservableData<T> {}

class Data<T> implements UnModifiableData<T>, ModifiableData<T> {
  T? _value;
  Failure? _failure;
  Operation _operation;

  bool _allowedToNotify = true;

  final List<void Function()> observers = [];
  final List<bool Function(Event event)> eventListeners = [];
  final List<dynamic> _sideEffects;

  final String? name;

  Data({
    T? value,
    Failure? failure,
    Operation operation = Operation.none,
    List<dynamic>? sideEffects,
    this.name,
  })  : _value = value,
        _failure = failure,
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
  Failure get consumeFailure {
    if (_failure == null) {
      throw FailureIsNullException();
    }
    Failure consumedFailureValue = _failure!;
    _failure = null;
    return consumedFailureValue;
  }

  @override
  Failure get failure {
    if (_failure == null) {
      throw FailureIsNullException();
    }
    return _failure!;
  }

  @override
  List<dynamic> get sideEffects => _sideEffects;

  @override
  void addSideEffect(dynamic sideEffect) {
    _sideEffects.add(sideEffect);
    dispatchEvent(AddSideEffectEvent(
      newSideEffect: sideEffect,
      sideEffects: _sideEffects,
    ));
    dispatchEvent(SideEffectsUpdated(_sideEffects));
    notifyObservers();
  }

  @override
  void addAllSideEffects(Iterable<dynamic> sideEffects) {
    _sideEffects.addAll(sideEffects);
    dispatchEvent(SideEffectsUpdated(_sideEffects));
    notifyObservers();
  }

  @override
  void removeSideEffect(dynamic sideEffect) {
    _sideEffects.remove(sideEffect);
    dispatchEvent(RemoveSideEffectEvent(
      removedSideEffect: sideEffect,
      sideEffects: _sideEffects,
    ));
    dispatchEvent(SideEffectsUpdated(_sideEffects));
    notifyObservers();
  }

  @override
  void clearAllSideEffects() {
    _sideEffects.clear();
    dispatchEvent(SideEffectsUpdated(_sideEffects));
    notifyObservers();
  }

  @override
  bool get hasSideEffects => _sideEffects.isNotEmpty;

  @override
  Failure? get failureOrNull => _failure;

  @override
  bool get hasFailure => _failure != null;

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
  void set failure(final Failure? failure) {
    _failure = failure;
    if (failure != null) {
      dispatchEvent(FailureEvent(failure));
    }
    notifyObservers();
  }

  @override
  void set operation(final Operation operation) {
    _operation = operation;
    dispatchEvent(OperationEvent(operation));
    notifyObservers();
  }

  Operation get operation => _operation;

  @override
  set value(final T? value) {
    _value = value;
    if (value != null) {
      dispatchEvent(ValueEvent(value));
    }
    notifyObservers();
  }

  @override
  void modify(void Function(Data<T> data) fn) {
    disallowNotify();
    final old = copy();
    fn(this);
    allowNotify();

    if (old._value != _value && _value != null) {
      dispatchEvent(ValueEvent(_value));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      dispatchEvent(FailureEvent(_failure!));
    }
    if (old.sideEffects != sideEffects) {
      dispatchEvent(SideEffectsUpdated(sideEffects));
    }

    notifyObservers();
  }

  @override
  Future<void> modifyAsync(Future<void> Function(Data<T> data) fn) async {
    disallowNotify();
    final old = copy();
    await fn(this);
    allowNotify();

    if (old._value != _value && _value != null) {
      dispatchEvent(ValueEvent(_value));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      dispatchEvent(FailureEvent(_failure!));
    }
    if (old.sideEffects != sideEffects) {
      dispatchEvent(SideEffectsUpdated(sideEffects));
    }

    notifyObservers();
  }

  @override
  void updateFrom(ReadableData<T> data) {
    disallowNotify();
    final old = copy();
    value = data.valueOrNull;
    operation = data.operation;
    failure = data.failureOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects);
    allowNotify();

    if (old._value != _value && _value != null) {
      dispatchEvent(ValueEvent(_value));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      dispatchEvent(FailureEvent(_failure!));
    }
    if (old.sideEffects != sideEffects) {
      dispatchEvent(SideEffectsUpdated(sideEffects));
    }

    notifyObservers();
  }

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() =>
      Data<T>(value: _value, failure: _failure, operation: _operation);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('{ ');
    if (name != null) {
      buffer.write('${inYellow(name)}:');
    }
    buffer.write('${inYellow(runtimeType)} = ');
    if (hasFailure) {
      buffer.write("failure: ${inRed('<')}");
      if (_failure?.id != null) {
        buffer.write(inRed('id: ${failure.id} - '));
      }
      if (_failure?.cause != null) {
        buffer.write(inRed('cause: ${failure.cause} - '));
      }
      buffer
          .write('${inRed("${ellipsize(failure.message, maxSize: 20)}> ")}| ');
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

    if (_failure != null) {
      buffer.write('$failure');
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is! Data<T>) return false;

    return other.runtimeType == runtimeType &&
        _failure == other._failure &&
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
  bool get hasEventListeners => eventListeners.isNotEmpty;

  @override
  void allowNotify() {
    _allowedToNotify = true;
  }

  @override
  void disallowNotify() {
    _allowedToNotify = false;
  }

  @override
  void notifyObservers() {
    if (_allowedToNotify) observers.forEach((observer) => observer());
  }

  @override
  void addEventListener(bool Function(Event event) listener) {
    eventListeners.add(listener);
  }

  @override
  void removeEventListener(bool Function(Event event) listener) {
    eventListeners.remove(listener);
  }

  @override
  void dispatchEvent(Event event) {
    if (_allowedToNotify) {
      for (var callback in eventListeners) {
        final eventConsumed = callback(event);
        if (eventConsumed) {
          break;
        }
      }
    }
  }
}
