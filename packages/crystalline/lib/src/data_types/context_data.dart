import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';

class ContextData<T, C> extends Data<T> {
  ContextData({
    T? value,
    Failure? failure,
    Operation operation = Operation.none,
    List<dynamic>? sideEffects,
    C? context,
  })  : _context = context,
        super(
          value: value,
          failure: failure,
          operation: operation,
          sideEffects: sideEffects,
        );

  C? _context;

  bool get hasContext => _context != null;

  void set context(C? context) {
    _context = context;
    notifyObservers();
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
  void updateFrom(ReadableData<T> data) {
    if (data is! ContextData<T, C>) {
      throw CannotUpdateFromTypeException(this, data);
    }
    disallowNotify();
    value = data.valueOrNull;
    operation = data.operation;
    failure = data.failureOrNull;
    context = data.context;
    removeAllSideEffects();
    addAllSideEffects(data.sideEffects);
    allowNotify();
    notifyObservers();
  }

  @override
  ContextData<T, C> copy() => ContextData(
        value: valueOrNull,
        failure: failureOrNull,
        operation: operation,
        context: contextOrNull,
        sideEffects: sideEffects.toList(),
      );
}
