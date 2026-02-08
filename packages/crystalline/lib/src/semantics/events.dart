import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/semantics/operation.dart';

class Events {
  bool _allowedToNotify = true;

  final List<bool Function(Event event)> _listeners = [];

  // returns a copy of current listeners added.
  List<bool Function(Event event)> get listeners => _listeners.toList();

  bool get hasListeners => _listeners.isNotEmpty;

  void addListener(bool Function(Event event) listener) {
    _listeners.add(listener);
  }

  void removeListener(bool Function(Event event) listener) {
    _listeners.remove(listener);
  }

  void dispatch(Event event) {
    if (_allowedToNotify) {
      for (final callback in _listeners) {
        final isEventConsumed = callback(event);
        if (isEventConsumed) {
          break;
        }
      }
    }
  }

  void allowNotify() => _allowedToNotify = true;

  void disallowNotify() => _allowedToNotify = false;
}

class RefreshDataEvents extends Events {
  final RefreshData _refreshData;

  RefreshDataEvents(this._refreshData);

  @override
  void addListener(bool Function(Event event) listener) {
    if (_refreshData.hasNoValue) _refreshData.refresh(allowRetry: false);
    super.addListener(listener);
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
