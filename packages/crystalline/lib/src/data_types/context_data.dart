import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/exceptions.dart';

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
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);
}
