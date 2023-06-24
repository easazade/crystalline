import 'package:crystalline/crystalline.dart';

class ContextData<T, C> extends Data<T> {
  ContextData({
    T? value,
    DataError? error,
    Operation operation = Operation.none,
    C? context,
  })  : _context = context,
        super(value: value, error: error, operation: operation);

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
  ContextData<T, C> copy() => ContextData(
        value: valueOrNull,
        error: errorOrNull,
        operation: operation,
        context: contextOrNull,
      );
}
