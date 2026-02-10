import 'dart:async';

import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:crystalline/src/semantics/events.dart';
import 'package:crystalline/src/semantics/observers.dart';
import 'package:crystalline/src/semantics/operation.dart';
import 'package:crystalline/src/semantics/side_effects.dart';
import 'package:meta/meta.dart';

part 'refresh_data.dart';

class Data<T> {
  Data({
    T? value,
    Failure? failure,
    Operation operation = Operation.none,
    Iterable<dynamic>? sideEffects,
    this.name,
  })  : _value = value,
        _failure = failure,
        _operation = operation {
    if (sideEffects != null) {
      this.sideEffects.addAll(sideEffects);
    }
  }

  T? _value;
  Failure? _failure;
  Operation _operation;

  bool _allowedToNotify = true;

  late final sideEffects = SideEffects(this, () => notifyObserversAndStreamListeners());
  late final observers = DataObservers(this);
  final events = Events();

  final String? name;

  @protected
  final streamController = StreamController<bool>.broadcast(sync: true);

  @mustBeOverridden
  Stream<Data<T>> get stream => streamController.stream.map((e) => this);

  T get value {
    if (_value == null) {
      throw const ValueNotAvailableException();
    }
    return _value!;
  }

  T? get valueOrNull => _value;

  Failure get consumeFailure {
    if (_failure == null) {
      throw const FailureIsNullException();
    }
    final consumedFailureValue = _failure!;
    _failure = null;
    return consumedFailureValue;
  }

  Failure get failure {
    if (_failure == null) {
      throw const FailureIsNullException();
    }
    return _failure!;
  }

  Failure? get failureOrNull => _failure;

  bool get hasFailure => _failure != null;

  bool get hasValue => _value != null;

  bool get hasNoValue => !hasValue;

  bool get isCreating => _operation == Operation.create;

  bool get isDeleting => _operation == Operation.delete;

  bool get isReading => _operation == Operation.read;

  bool get isUpdating => _operation == Operation.update;

  bool get hasCustomOperation => _operation.isCustom;

  bool get isAnyOperation => _operation != Operation.none;

  bool valueEqualsTo(T? otherValue) => _value == otherValue;

  set failure(final Failure? failure) {
    _failure = failure;
    if (failure != null) {
      events.dispatch(FailureEvent(failure));
    }
    notifyObserversAndStreamListeners();
  }

  set operation(final Operation operation) {
    _operation = operation;
    events.dispatch(OperationEvent(operation));
    notifyObserversAndStreamListeners();
  }

  Operation get operation => _operation;

  set value(final T? value) {
    _value = value;
    if (value != null) {
      events.dispatch(ValueEvent(value));
    }
    notifyObserversAndStreamListeners();
  }

  void modify(void Function(Data<T> data) fn) {
    disallowNotify();
    final old = copy();
    fn(this);
    allowNotify();

    if (old._value != _value && hasValue) {
      events.dispatch(ValueEvent(value));
    }
    if (old.operation != operation) {
      events.dispatch(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      events.dispatch(FailureEvent(_failure!));
    }
    if (!const ListEquality<dynamic>().equals(old.sideEffects.all.toList(), sideEffects.all.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects.all));
    }

    notifyObserversAndStreamListeners();
  }

  Future<void> modifyAsync(Future<void> Function(Data<T> data) fn) async {
    disallowNotify();
    final old = copy();
    await fn(this);
    allowNotify();

    if (old._value != _value && hasValue) {
      events.dispatch(ValueEvent(value));
    }
    if (old.operation != operation) {
      events.dispatch(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      events.dispatch(FailureEvent(_failure!));
    }
    if (!const ListEquality<dynamic>().equals(old.sideEffects.all.toList(), sideEffects.all.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects.all));
    }

    notifyObserversAndStreamListeners();
  }

  void updateFrom(Data<T> data) {
    disallowNotify();
    final old = copy();
    value = data.valueOrNull;
    operation = data.operation;
    failure = data.failureOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects.all);
    allowNotify();

    if (old._value != _value && hasValue) {
      events.dispatch(ValueEvent(value));
    }
    if (old.operation != operation) {
      events.dispatch(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      events.dispatch(FailureEvent(_failure!));
    }
    if (!const ListEquality<dynamic>().equals(old.sideEffects.all.toList(), sideEffects.all.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects.all));
    }

    notifyObserversAndStreamListeners();
  }

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

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() => Data<T>(value: _value, failure: _failure, operation: _operation);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (other is! Data<T>) return false;

    return other.runtimeType == runtimeType &&
        _failure == other._failure &&
        _value == other._value &&
        _operation == other._operation &&
        ListEquality().equals(sideEffects.all.toList(), other.sideEffects.all.toList());
  }

  @override
  @mustBeOverridden
  int get hashCode =>
      (_failure?.hashCode ?? 0) +
      (_value?.hashCode ?? 4) +
      sideEffects.all.hashCode +
      _operation.hashCode +
      runtimeType.hashCode;

  void allowNotify() {
    _allowedToNotify = true;
    observers.allowNotify();
    events.allowNotify();
  }

  void disallowNotify() {
    _allowedToNotify = false;
    observers.disallowNotify();
    events.disallowNotify();
  }

  bool get isAllowedToNotify => _allowedToNotify;

  @protected
  void notifyObserversAndStreamListeners() {
    observers.notify();
    if (_allowedToNotify) {
      streamController.add(true);
    }
  }
}
