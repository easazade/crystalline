import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:meta/meta.dart';

class ContextData<T, C> extends Data<T> {
  ContextData({
    super.value,
    C? context,
    super.failure,
    super.operation,
    List<dynamic>? super.sideEffects,
    super.name,
  }) : _context = context;

  C? _context;

  bool get hasContext => _context != null;

  set context(C? context) {
    _context = context;
    observers.notify();
  }

  C get context {
    if (_context == null) {
      throw ContextIsNullException();
    }
    return _context!;
  }

  C? get contextOrNull => _context;

  @override
  void modify(void Function(ContextData<T, C> data) fn) {
    super.modify((data) => fn(data as ContextData<T, C>));
  }

  @override
  Future<void> modifyAsync(
    Future<void> Function(ContextData<T, C> data) fn,
  ) {
    return super.modifyAsync((data) => fn(data as ContextData<T, C>));
  }

  @override
  void updateFrom(Data<T> data) {
    if (data is! ContextData<T, C>) {
      throw CannotUpdateFromTypeException(this, data);
    }
    disallowNotify();
    value = data.valueOrNull;
    operation = data.operation;
    failure = data.failureOrNull;
    context = data.context;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects.all);
    allowNotify();
    observers.notify();
  }

  @override
  void reset() {
    _context = null;
    super.reset();
  }

  @override
  ContextData<T, C> copy() => ContextData(
        value: valueOrNull,
        failure: failureOrNull,
        operation: operation,
        context: contextOrNull,
        sideEffects: sideEffects.all.toList(),
      );

  @override
  Stream<ContextData<T, C>> get stream => streamController.stream.map((e) => this);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (other is! ContextData<T, C>) return false;

    return other.runtimeType == runtimeType &&
        failureOrNull == other.failureOrNull &&
        valueOrNull == other.valueOrNull &&
        operation == other.operation &&
        ListEquality().equals(sideEffects.all.toList(), other.sideEffects.all.toList());
  }

  @override
  @mustBeOverridden
  int get hashCode =>
      (failureOrNull?.hashCode ?? 13) +
      (valueOrNull?.hashCode ?? 8) +
      sideEffects.all.hashCode +
      operation.hashCode +
      runtimeType.hashCode;
}
