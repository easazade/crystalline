class Operation {
  const Operation(this.name);
  static const Operation create = Operation('create');
  static const Operation read = Operation('read');
  static const Operation update = Operation('update');
  static const Operation delete = Operation('delete');

  static final List<Operation> defaultOperations = [create, read, update, delete];

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
  int get hashCode => name.hashCode;
}
