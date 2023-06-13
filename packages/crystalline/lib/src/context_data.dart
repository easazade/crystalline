import 'package:crystalline/crystalline.dart';

class ContextData<T, C> extends Data<T> {
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
}
