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
    observers.forEach((observer) => observer());
  }

  C get context {
    if (_context == null) {
      throw ContextIsNullException();
    }
    return _context!;
  }

  C? get contextOrNull => _context;

  @override
  ContextData<T, C> copy() => ContextData(
        value: valueOrNull,
        error: errorOrNull,
        operation: operation,
        context: contextOrNull,
      );
}
