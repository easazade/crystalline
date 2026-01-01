import 'dart:async';

import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:meta/meta.dart';

class Operation {
  const Operation(this.name);
  static const Operation update = Operation('update');
  static const Operation delete = Operation('delete');
  static const Operation read = Operation('read');
  static const Operation create = Operation('create');
  static const Operation none = Operation('none');

  static final List<Operation> defaultOperations = [
    update,
    delete,
    read,
    create,
    none,
  ];

  final String name;

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

  @override
  int get hashCode => name.hashCode + 4;
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
  int get hashCode => name.hashCode + 12;

  @override
  String toString() => name;
}

class OperationEvent extends Event {
  OperationEvent(this.operation) : super(operation.name);

  final Operation operation;
}

class ValueEvent<T> extends Event {
  ValueEvent(this.value) : super(CrystallineGlobalConfig.logger.ellipsize(value.toString(), maxSize: 20));

  final T value;
}

class FailureEvent extends Event {
  FailureEvent(this.failure) : super(CrystallineGlobalConfig.logger.ellipsize(failure.message, maxSize: 20));

  final Failure failure;
}

class SideEffectsUpdatedEvent extends Event {
  SideEffectsUpdatedEvent(this.sideEffects) : super('sideEffects: ${sideEffects.length}');
  final Iterable<dynamic> sideEffects;
}

class AddSideEffectEvent extends Event {
  AddSideEffectEvent({
    required this.newSideEffect,
    required this.sideEffects,
  }) : super(CrystallineGlobalConfig.logger.ellipsize(newSideEffect.toString(), maxSize: 20));
  final dynamic newSideEffect;
  final List<dynamic> sideEffects;
}

class RemoveSideEffectEvent extends Event {
  RemoveSideEffectEvent({
    required this.removedSideEffect,
    required this.sideEffects,
  }) : super(
          CrystallineGlobalConfig.logger.ellipsize(
            removedSideEffect.toString(),
            maxSize: 20,
          ),
        );
  final dynamic removedSideEffect;
  final List<dynamic> sideEffects;
}

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

  final List<void Function()> _observers = [];
  final List<bool Function(Event event)> _eventListeners = [];
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
    dispatchEvent(
      AddSideEffectEvent(
        newSideEffect: sideEffect,
        sideEffects: _sideEffects,
      ),
    );
    dispatchEvent(SideEffectsUpdatedEvent(_sideEffects));
    notifyObservers();
  }

  void addAllSideEffects(Iterable<dynamic> sideEffects) {
    _sideEffects.addAll(sideEffects);
    dispatchEvent(SideEffectsUpdatedEvent(_sideEffects));
    notifyObservers();
  }

  void removeSideEffect(dynamic sideEffect) {
    _sideEffects.remove(sideEffect);
    dispatchEvent(
      RemoveSideEffectEvent(
        removedSideEffect: sideEffect,
        sideEffects: _sideEffects,
      ),
    );
    dispatchEvent(SideEffectsUpdatedEvent(_sideEffects));
    notifyObservers();
  }

  void removeAllSideEffects() {
    _sideEffects.clear();
    dispatchEvent(SideEffectsUpdatedEvent(_sideEffects));
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
      dispatchEvent(FailureEvent(failure));
    }
    notifyObservers();
  }

  set operation(final Operation operation) {
    _operation = operation;
    dispatchEvent(OperationEvent(operation));
    notifyObservers();
  }

  Operation get operation => _operation;

  set value(final T? value) {
    _value = value;
    if (value != null) {
      dispatchEvent(ValueEvent(value));
    }
    notifyObservers();
  }

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
    if (!const ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      dispatchEvent(SideEffectsUpdatedEvent(sideEffects));
    }

    notifyObservers();
  }

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
    if (!const ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      dispatchEvent(SideEffectsUpdatedEvent(sideEffects));
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
      dispatchEvent(ValueEvent(value));
    }
    if (old.operation != operation) {
      dispatchEvent(OperationEvent(operation));
    }
    if (old._failure != _failure && _failure != null) {
      dispatchEvent(FailureEvent(_failure!));
    }
    if (!const ListEquality<dynamic>().equals(old.sideEffects.toList(), sideEffects.toList())) {
      dispatchEvent(SideEffectsUpdatedEvent(sideEffects));
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

  bool get hasEventListeners => eventListeners.isNotEmpty;

  void allowNotify() {
    _allowedToNotify = true;
  }

  void disallowNotify() {
    _allowedToNotify = false;
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

  Iterable<bool Function(Event event)> get eventListeners => _eventListeners;

  void addEventListener(bool Function(Event event) listener) {
    _eventListeners.add(listener);
  }

  void removeEventListener(bool Function(Event event) listener) {
    _eventListeners.remove(listener);
  }

  void dispatchEvent(Event event) {
    if (_allowedToNotify) {
      for (final callback in eventListeners) {
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
    required Future<RefreshStatus> Function(RefreshData<T> currentData) refresh,
    super.value,
    super.failure,
    super.operation,
    List<dynamic>? super.sideEffects,
    super.name,
    this.retryDelay = const Duration(milliseconds: 1000),
    this.maxRetry = 1,
  }) : _refreshCallback = refresh;

  final Future<RefreshStatus> Function(RefreshData<T> currentData) _refreshCallback;
  final Duration retryDelay;
  final int maxRetry;
  RefreshStatus _status = RefreshStatus.failed;

  Completer<void>? _refreshCompleter;
  var _disposed = false;

  Future<void> refresh({bool allowRetry = true}) async {
    if (_disposed) {
      return;
    }

    Future<RefreshStatus> tryRefreshCallback() async {
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

    final isRefreshing = _refreshCompleter != null && !_refreshCompleter!.isCompleted;

    if (_value == null && !isRefreshing) {
      _refreshCompleter = Completer();

      _log(CrystallineGlobalConfig.logger.greenText('Refreshing ${name ?? "RefreshData<$T>"}'));
      _status = await tryRefreshCallback();

      if (_status == RefreshStatus.failed) {
        _log(
          CrystallineGlobalConfig.logger.redText(
            '❌ Refresh failed for ${name ?? "RefreshData<$T>"} retrying after $retryDelay | failure: $failureOrNull',
          ),
        );

        var retryCount = 1;
        while (retryCount <= maxRetry && _status == RefreshStatus.failed) {
          _log(CrystallineGlobalConfig.logger.yellowText('Retry attempt $retryCount'));
          _status = await tryRefreshCallback();
          _log(CrystallineGlobalConfig.logger.yellowText('Retry attempt result: status: $_status | data: $this'));
          retryCount += 1;
        }
        if (_status == RefreshStatus.done) {
          _log(
            CrystallineGlobalConfig.logger.greenText(
              '✅ Refreshed on Retry attempt $retryCount ${name ?? "RefreshData<$T>"} | status: $_status | operation: $operation | value: $valueOrNull',
            ),
          );
        } else {
          _log(
            CrystallineGlobalConfig.logger.redText(
              '❌ All refresh retry attempts failed for ${name ?? "RefreshData<$T>"} | failure: $failureOrNull',
            ),
          );
        }
      } else {
        _log(
          CrystallineGlobalConfig.logger.greenText(
            '✅ Refreshed ${name ?? "RefreshData<$T>"} | status: $_status | operation: $operation | value: $valueOrNull',
          ),
        );

        if (operation != Operation.none) {
          _log(
            CrystallineGlobalConfig.logger.orangeText(
              '⚠️ Operation after successful refresh was not set to Operation.none. '
              'Usually it is desired to set the Operation to Operation.none when there is no operation is going on anymore. '
              'Please implement refresh callback for RefreshData object to do so.',
            ),
          );
        }
      }

      _refreshCompleter?.complete();
    }

    return _refreshCompleter?.future;
  }

  void _log(String msg) {
    CrystallineGlobalConfig.logger.log(msg);
  }

  Future<void> ensureRefreshComplete() => _refreshCompleter?.future ?? Future.value();

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
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

  void dispose() {
    _disposed = true;
    _observers.clear();
    _eventListeners.clear();
    reset();
  }
}

enum RefreshStatus { done, failed }
