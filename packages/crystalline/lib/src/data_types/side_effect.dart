import 'dart:collection';

abstract class SideEffect {}

class SemanticSideEffects with ListMixin<SideEffect> {
  List<SideEffect> _sideffects = [];

  @override
  int get length => _sideffects.length;

  @override
  SideEffect operator [](int index) => _sideffects[index];

  @override
  void operator []=(int index, SideEffect value) => _sideffects[index] = value;

  @override
  set length(int newLength) {
    _sideffects = _sideffects.sublist(0, newLength);
  }
}

class DataError implements Exception, SideEffect {
  DataError(this.message, {this.id});

  final String message;
  final String? id;

  @override
  String toString() => '${id != null ? "error-id: $id -> " : ""}$message\n'
      '${super.toString()}';
}
