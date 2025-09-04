import 'dart:async';

import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:meta/meta.dart';

class Operation {
  static const Operation update = Operation('update');
  static const Operation delete = Operation('delete');
  static const Operation read = Operation('read');
  static const Operation create = Operation('create');
  static const Operation none = Operation('none');

  static final defaultOperations = [
    update,
    delete,
    read,
    create,
    none,
  ];

  final String name;

  const Operation(this.name);

  bool get isCustom => !defaultOperations.contains(this);

  @override
  String toString() => 'Operation.$name';

  @override
  bool operator ==(Object other) {
    if (other is! Operation) {
      return false;
    } else {
      return name == other.name;
    }
  }
}

class Event {
  const Event(this.name);

  final String name;

  @override
  bool operator ==(Object other) {
    if (other is! Event) return false;
    return other.runtimeType == runtimeType && name == other.name;
  }

  @override
  String toString() => name;
}

class OperationEvent extends Event {
  OperationEvent(this.operation) : super(operation.name);

  final Operation operation;
}

class ValueEvent<T> extends Event {
  ValueEvent(this.value)
      : super(CrystallineGlobalConfig.logger
            .ellipsize(value.toString(), maxSize: 20));

  final T value;
}

class FailureEvent extends Event {
  FailureEvent(this.failure)
      : super(CrystallineGlobalConfig.logger
            .ellipsize(failure.message, maxSize: 20));

  final Failure failure;
}

class SideEffectsUpdated extends Event {
  final Iterable<dynamic> sideEffects;

  SideEffectsUpdated(this.sideEffects)
      : super('sideEffects: ${sideEffects.length}');
}

class AddSideEffectEvent extends Event {
  final dynamic newSideEffect;
  final List<dynamic> sideEffects;

  AddSideEffectEvent({
    required this.newSideEffect,
    required this.sideEffects,
  }) : super(CrystallineGlobalConfig.logger
            .ellipsize(newSideEffect.toString(), maxSize: 20));
}

class RemoveSideEffectEvent extends Event {
  final dynamic removedSideEffect;
  final List<dynamic> sideEffects;

  RemoveSideEffectEvent({
    required this.removedSideEffect,
    required this.sideEffects,
  }) : super(CrystallineGlobalConfig.logger.ellipsize(
          removedSideEffect.toString(),
          maxSize: 20,
        ));
}

abstract class ReadableData<T> {
  T get value;

  T? get valueOrNull;

  Failure get failure;

  Failure? get failureOrNull;

  Operation get operation;

  Failure get consumeFailure;

  Iterable<dynamic> get sideEffects;

  bool get hasSideEffects;

  bool get hasValue;

  bool get hasNoValue;

  bool get isAnyOperation;

  bool get isUpdating;

  bool get isDeleting;

  bool get isReading;

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

  void removeAllSideEffects();

  void modify(void Function(Data<T> data) fn);

  Future<void> modifyAsync(Future<void> Function(Data<T> data) fn);

  void updateFrom(ReadableData<T> data);

  void reset();
}

abstract class ObservableData<T> implements ReadableData<T> {
  void addObserver(void Function() observer);

  void removeObserver(void Function() observer);

  bool get hasObservers;

  Iterable<void Function()> get observers;

  Iterable<bool Function(Event event)> get eventListeners;

  bool get hasEventListeners;

  void addEventListener(bool Function(Event event) listener);

  void removeEventListener(bool Function(Event event) listener);

  void dispatchEvent(Event event);

  bool get isAllowedToNotify;

  @mustCallSuper
  void allowNotify();

  @mustCallSuper
  void disallowNotify();

  @mustCallSuper
  void notifyObservers();
}

class Data<T> implements ObservableData<T>, ModifiableData<T> {
  T? _value;
  Failure? _failure;
  Operation _operation;

  bool _allowedToNotify = true;

  final List<void Function()> _observers = [];
  final List<bool Function(Event event)> _eventListeners = [];
  final List<dynamic> _sideEffects;

  final String? name;

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
  Iterable<dynamic> get sideEffects => _sideEffects;

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
  void removeAllSideEffects() {
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

    if (old._value != _value && hasValue) {
      dispatchEvent(ValueEvent(value));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      dispatchEvent(FailureEvent(_failure!));
    }
    if (!ListEquality<dynamic>()
        .equals(old.sideEffects.toList(), sideEffects.toList())) {
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

    if (old._value != _value && hasValue) {
      dispatchEvent(ValueEvent(value));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      dispatchEvent(FailureEvent(_failure!));
    }
    if (!ListEquality<dynamic>()
        .equals(old.sideEffects.toList(), sideEffects.toList())) {
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
    _sideEffects.clear();
    _sideEffects.addAll(data.sideEffects);
    allowNotify();

    if (old._value != _value && hasValue) {
      dispatchEvent(ValueEvent(value));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      dispatchEvent(FailureEvent(_failure!));
    }
    if (!ListEquality<dynamic>()
        .equals(old.sideEffects.toList(), sideEffects.toList())) {
      dispatchEvent(SideEffectsUpdated(sideEffects));
    }

    notifyObservers();
  }

  /// Resets the Data by setting value & failure to null, sets operation to Operation.none and removes all side-effects
  @override
  void reset() {
    modify((data) {
      data.value = null;
      data.operation = Operation.none;
      data.failure = null;
      data.removeAllSideEffects();
    });
  }

  /// returns a new instance of data object which is copy of this object.
  Data<T> copy() =>
      Data<T>(value: _value, failure: _failure, operation: _operation);

  @override
  String toString() =>
      CrystallineGlobalConfig.logger.generateToStringForData(this);

  @override
  bool operator ==(Object other) {
    if (other is! Data<T>) return false;

    return other.runtimeType == runtimeType &&
        _failure == other._failure &&
        _value == other._value &&
        _operation == other._operation;
  }

  @override
  Iterable<void Function()> get observers => _observers;

  @override
  void addObserver(void Function() observer) {
    _observers.add(observer);
  }

  @override
  void removeObserver(void Function() observer) {
    _observers.remove(observer);
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
  bool get isAllowedToNotify => _allowedToNotify;

  @mustCallSuper
  void notifyObservers() {
    final stateChangeLog = CrystallineGlobalConfig.logger.globalLogFilter(this);
    if (stateChangeLog != null) {
      CrystallineGlobalConfig.logger.log(stateChangeLog);
    }
    if (isAllowedToNotify) observers.forEach((observer) => observer());
  }

  @override
  Iterable<bool Function(Event event)> get eventListeners => _eventListeners;

  @override
  void addEventListener(bool Function(Event event) listener) {
    _eventListeners.add(listener);
  }

  @override
  void removeEventListener(bool Function(Event event) listener) {
    _eventListeners.remove(listener);
  }

  @override
  void dispatchEvent(Event event) {
    if (_allowedToNotify) {
      for (var callback in eventListeners) {
        final isEventConsumed = callback(event);
        if (isEventConsumed) {
          break;
        }
      }
    }
  }
}

class RefreshData<T> extends Data<T> {
  RefreshData({
    T? value,
    Failure? failure,
    Operation operation = Operation.none,
    List<dynamic>? sideEffects,
    String? name,
    required Future<RefreshStatus> Function(RefreshData<T> currentData) refresh,
    this.retryDelay = const Duration(milliseconds: 1000),
    this.maxRetry = 1,
  })  : _refreshCallback = refresh,
        super(
          value: value,
          failure: failure,
          operation: operation,
          sideEffects: sideEffects,
          name: name,
        );

  Future<RefreshStatus> Function(RefreshData<T> currentData) _refreshCallback;
  final Duration retryDelay;
  final int maxRetry;
  RefreshStatus _status = RefreshStatus.failed;

  Completer<void>? _refreshCompleter;

  Future<void> refresh({bool allowRetry = true}) async {
    Future<RefreshStatus> _tryRefreshCallback() async {
      RefreshStatus status;

      try {
        status = await _refreshCallback(this);
      } catch (e, stack) {
        status = RefreshStatus.failed;
        print(e);
        print(stack);
      }

      return status;
    }

    final isRefreshing =
        _refreshCompleter != null && !_refreshCompleter!.isCompleted;

    if (_value == null && !isRefreshing) {
      _refreshCompleter = Completer();

      _log(CrystallineGlobalConfig.logger
          .greenText('Refreshing ${name ?? "RefreshData<$T>"}'));
      _status = await _tryRefreshCallback();

      if (_status == RefreshStatus.failed) {
        _log(CrystallineGlobalConfig.logger.redText(
          '❌ Refresh failed for ${name ?? "RefreshData<$T>"} retrying after ${retryDelay} | failure: ${failureOrNull}',
        ));

        int retryCount = 1;
        while (retryCount <= maxRetry && _status == RefreshStatus.failed) {
          _log(CrystallineGlobalConfig.logger
              .yellowText('Retry attempt $retryCount'));
          _status = await _tryRefreshCallback();
          _log(CrystallineGlobalConfig.logger.yellowText(
              'Retry attempt result: status: ${_status} | data: ${this}'));
          retryCount += 1;
        }
        if (_status == RefreshStatus.done) {
          _log(CrystallineGlobalConfig.logger.greenText(
            '✅ Refreshed on Retry attempt $retryCount ${name ?? "RefreshData<$T>"} | status: $_status | operation: $operation | value: $valueOrNull',
          ));
        } else {
          _log(CrystallineGlobalConfig.logger.redText(
            '❌ All refresh retry attempts failed for ${name ?? "RefreshData<$T>"} | failure: ${failureOrNull}',
          ));
        }
      } else {
        _log(CrystallineGlobalConfig.logger.greenText(
          '✅ Refreshed ${name ?? "RefreshData<$T>"} | status: $_status | operation: $operation | value: $valueOrNull',
        ));

        if (operation != Operation.none) {
          _log(CrystallineGlobalConfig.logger.orangeText(
            '⚠️ Operation after successful refresh was not set to Operation.none. '
            'Usually it is desired to set the Operation to Operation.none when there is no operation is going on anymore. '
            'Please implement refresh callback for RefreshData object to do so.',
          ));
        }
      }

      _refreshCompleter?.complete();
    }

    return _refreshCompleter?.future;
  }

  void _log(String msg) {
    CrystallineGlobalConfig.logger.log(msg);
  }

  Future<void> ensureRefreshComplete() =>
      _refreshCompleter?.future ?? Future.value();

  RefreshStatus get status => _status;

  @override
  void addEventListener(bool Function(Event event) listener) {
    if (_value == null) refresh(allowRetry: false);
    super.addEventListener(listener);
  }

  @override
  void addObserver(void Function() observer) {
    if (_value == null) refresh(allowRetry: false);
    super.addObserver(observer);
  }

  @override
  String toString() =>
      CrystallineGlobalConfig.logger.generateToStringForData(this);
}

enum RefreshStatus { done, failed }
