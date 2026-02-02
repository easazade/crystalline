import 'dart:async';

import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:crystalline/src/semantics/events.dart';
import 'package:crystalline/src/semantics/operation.dart';
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
        _sideEffects = sideEffects?.toList() ?? [],
        _operation = operation;
  T? _value;
  Failure? _failure;
  Operation _operation;

  bool _allowedToNotify = true;

  final events = Events();
  final List<void Function()> _observers = [];
  final List<dynamic> _sideEffects;

  final String? name;

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

  Iterable<dynamic> get sideEffects => _sideEffects;

  void addSideEffect(dynamic sideEffect) {
    _sideEffects.add(sideEffect);
    events.dispatch(
      AddSideEffectEvent(
        newSideEffect: sideEffect,
        sideEffects: _sideEffects,
      ),
    );
    events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    notifyObservers();
  }

  void addAllSideEffects(Iterable<dynamic> sideEffects) {
    _sideEffects.addAll(sideEffects);
    events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    notifyObservers();
  }

  void removeSideEffect(dynamic sideEffect) {
    _sideEffects.remove(sideEffect);
    events.dispatch(
      RemoveSideEffectEvent(
        removedSideEffect: sideEffect,
        sideEffects: _sideEffects,
      ),
    );
    events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    notifyObservers();
  }

  void removeAllSideEffects() {
    _sideEffects.clear();
    events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    notifyObservers();
  }

  bool get hasSideEffects => _sideEffects.isNotEmpty;

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
    notifyObservers();
  }

  set operation(final Operation operation) {
    _operation = operation;
    events.dispatch(OperationEvent(operation));
    notifyObservers();
  }

  Operation get operation => _operation;

  set value(final T? value) {
    _value = value;
    if (value != null) {
      events.dispatch(ValueEvent(value));
    }
    notifyObservers();
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
    if (!const ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects));
    }

    notifyObservers();
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
    if (!const ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects));
    }

    notifyObservers();
  }

  void updateFrom(Data<T> data) {
    disallowNotify();
    final old = copy();
    value = data.valueOrNull;
    operation = data.operation;
    failure = data.failureOrNull;
    _sideEffects.clear();
    _sideEffects.addAll(data.sideEffects);
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
    if (!const ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      events.dispatch(SideEffectsUpdatedEvent(sideEffects));
    }

    notifyObservers();
  }

  /// Resets the Data by setting value & failure to null, sets operation to Operation.none and removes all side-effects
  void reset() {
    modify((data) {
      data.value = null;
      data.operation = Operation.none;
      data.failure = null;
      data.removeAllSideEffects();
    });
  }

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() => Data<T>(value: _value, failure: _failure, operation: _operation);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

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

  Iterable<void Function()> get observers => _observers;

  void addObserver(void Function() observer) {
    _observers.add(observer);
  }

  void removeObserver(void Function() observer) {
    _observers.remove(observer);
  }

  bool get hasObservers => observers.isNotEmpty;

  void allowNotify() {
    _allowedToNotify = true;
    events.allowNotify();
  }

  void disallowNotify() {
    _allowedToNotify = false;
    events.disallowNotify();
  }

  bool get isAllowedToNotify => _allowedToNotify;

  @mustCallSuper
  void notifyObservers() {
    final stateChangeLog = CrystallineGlobalConfig.logger.globalLogFilter(this);
    if (stateChangeLog != null) {
      CrystallineGlobalConfig.logger.log(stateChangeLog);
    }
    if (isAllowedToNotify) {
      for (final observer in observers) {
        observer();
      }
    }
  }
}
