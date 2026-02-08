import 'dart:async';

import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:crystalline/src/semantics/events.dart';
import 'package:crystalline/src/semantics/observers.dart';
import 'package:crystalline/src/semantics/operation.dart';
import 'package:crystalline/src/semantics/side_effects.dart';

part 'refresh_data.dart';

/// Base interface for observable data that provides read-only access to data properties.
abstract interface class BaseObservableData<T> {
  T get value;
  T? get valueOrNull;
  Failure get consumeFailure;
  Failure get failure;
  Failure? get failureOrNull;
  bool get hasFailure;
  bool get hasValue;
  bool get hasNoValue;
  bool get isCreating;
  bool get isDeleting;
  bool get isReading;
  bool get isUpdating;
  bool get hasCustomOperation;
  bool get isAnyOperation;
  Operation get operation;
  bool get isAllowedToNotify;
  SideEffects<T> get sideEffects;

  bool valueEqualsTo(T? otherValue);
  Data<T> copy();

  @override
  String toString();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

/// Base interface for modifiable data that provides methods to modify data properties.
abstract interface class BaseModifiableData<T> implements BaseObservableData<T> {
  set failure(Failure? failure);
  set operation(Operation operation);
  set value(T? value);

  void modify(void Function(BaseModifiableData<T> data) fn);
  Future<void> modifyAsync(Future<void> Function(BaseModifiableData<T> data) fn);
  void updateFrom(BaseModifiableData<T> data);
  void reset();
  void allowNotify();
  void disallowNotify();
}

class BaseData<T> {
  BaseData({
    T? value,
    Failure? failure,
    Operation operation = Operation.none,
    Iterable<dynamic>? sideEffects,
    this.name,
  })  : _value = value,
        _failure = failure,
        _operation = operation,
        _initialSideEffects = sideEffects;

  T? _value;
  Failure? _failure;
  Operation _operation;

  bool _allowedToNotify = true;

  final Iterable<dynamic>? _initialSideEffects;

  late final SideEffects<T> sideEffects = () {
    final effects = SideEffects(this as Data<T>);
    if (_initialSideEffects != null) {
      effects.addAll(_initialSideEffects!);
    }
    return effects;
  }();

  late final DataObservers observers = DataObservers(this as Data<T>);
  final events = Events();

  final String? name;
}

mixin ObservableDataMixin<T> on BaseData<T> implements BaseObservableData<T> {
  @override
  T get value {
    if (_value == null) {
      throw const ValueNotAvailableException();
    }
    return _value!;
  }

  @override
  T? get valueOrNull => _value;

  @override
  Failure get consumeFailure {
    if (_failure == null) {
      throw const FailureIsNullException();
    }
    final consumedFailureValue = _failure!;
    _failure = null;
    return consumedFailureValue;
  }

  @override
  Failure get failure {
    if (_failure == null) {
      throw const FailureIsNullException();
    }
    return _failure!;
  }

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
  bool get isReading => _operation == Operation.read;

  @override
  bool get isUpdating => _operation == Operation.update;

  @override
  bool get hasCustomOperation => _operation.isCustom;

  @override
  bool get isAnyOperation => _operation != Operation.none;

  @override
  bool valueEqualsTo(T? otherValue) => _value == otherValue;

  @override
  Operation get operation => _operation;

  @override
  bool get isAllowedToNotify => _allowedToNotify;

  @override
  Data<T> copy() => Data<T>(value: _value, failure: _failure, operation: _operation);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this as Data<T>);

  @override
  bool operator ==(Object other) {
    if (other is! Data<T>) return false;

    return other.runtimeType == runtimeType &&
        _failure == other._failure &&
        _value == other._value &&
        _operation == other._operation;
  }

  @override
  int get hashCode => (_failure?.hashCode ?? 0) + (_value?.hashCode ?? 4) + _operation.hashCode + runtimeType.hashCode;
}

mixin ModifiableDataMixin<T> on BaseData<T> implements BaseModifiableData<T> {
  @override
  set failure(final Failure? failure) {
    _failure = failure;
    if (failure != null) {
      events.dispatch(FailureEvent(failure));
    }
    observers.notify();
  }

  @override
  set operation(final Operation operation) {
    _operation = operation;
    events.dispatch(OperationEvent(operation));
    observers.notify();
  }

  @override
  set value(final T? value) {
    _value = value;
    if (value != null) {
      events.dispatch(ValueEvent(value));
    }
    observers.notify();
  }

  @override
  void modify(void Function(BaseModifiableData<T> data) fn) {
    disallowNotify();
    final old = (this as BaseObservableData<T>).copy();
    fn(this as BaseModifiableData<T>);
    allowNotify();

    final self = this as BaseObservableData<T>;
    final oldValue = old.valueOrNull;
    if (oldValue != _value && self.hasValue) {
      events.dispatch(ValueEvent(self.value));
    }
    if (old.operation != self.operation) {
      events.dispatch(OperationEvent(self.operation));
    }
    final oldFailure = old.failureOrNull;
    if (oldFailure != _failure && _failure != null) {
      events.dispatch(FailureEvent(_failure!));
    }
    if (!const ListEquality<dynamic>().equals(old.sideEffects.all.toList(), sideEffects.all.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects.all));
    }

    observers.notify();
  }

  @override
  Future<void> modifyAsync(Future<void> Function(BaseModifiableData<T> data) fn) async {
    disallowNotify();
    final old = (this as BaseObservableData<T>).copy();
    await fn(this as BaseModifiableData<T>);
    allowNotify();

    final self = this as BaseObservableData<T>;
    final oldValue = old.valueOrNull;
    if (oldValue != _value && self.hasValue) {
      events.dispatch(ValueEvent(self.value));
    }
    if (old.operation != self.operation) {
      events.dispatch(OperationEvent(self.operation));
    }
    final oldFailure = old.failureOrNull;
    if (oldFailure != _failure && _failure != null) {
      events.dispatch(FailureEvent(_failure!));
    }
    if (!const ListEquality<dynamic>().equals(old.sideEffects.all.toList(), sideEffects.all.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects.all));
    }

    observers.notify();
  }

  @override
  void updateFrom(BaseModifiableData<T> data) {
    disallowNotify();
    final old = (this as BaseObservableData<T>).copy();
    final self = this as BaseObservableData<T>;
    value = data.valueOrNull;
    operation = data.operation;
    failure = data.failureOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects.all);
    allowNotify();

    final oldValue = old.valueOrNull;
    if (oldValue != _value && self.hasValue) {
      events.dispatch(ValueEvent(self.value));
    }
    if (old.operation != self.operation) {
      events.dispatch(OperationEvent(self.operation));
    }
    final oldFailure = old.failureOrNull;
    if (oldFailure != _failure && _failure != null) {
      events.dispatch(FailureEvent(_failure!));
    }
    if (!const ListEquality<dynamic>().equals(old.sideEffects.all.toList(), sideEffects.all.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects.all));
    }

    observers.notify();
  }

  @override

  /// Resets the Data by setting value & failure to null, sets operation to Operation.none and removes all side-effects
  /// It doesn't remove any observer or event-listener
  void reset() {
    modify((data) {
      data.value = null;
      data.operation = Operation.none;
      data.failure = null;
      data.sideEffects.clear();
    });
  }

  @override
  void allowNotify() {
    _allowedToNotify = true;
    observers.allowNotify();
    events.allowNotify();
  }

  @override
  void disallowNotify() {
    _allowedToNotify = false;
    observers.disallowNotify();
    events.disallowNotify();
  }
}

class ObservableData<T> extends BaseData<T> with ObservableDataMixin<T> {
  ObservableData({
    super.value,
    super.failure,
    super.operation = Operation.none,
    super.sideEffects,
    super.name,
  });
}

class Data<T> extends ObservableData<T> with ModifiableDataMixin<T> {
  Data({
    super.value,
    super.failure,
    super.operation = Operation.none,
    super.sideEffects,
    super.name,
  });
}
