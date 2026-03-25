class StoreClass {
  const StoreClass();
}

class SharedData {
  const SharedData();
}

class CustomSideEffect {
  const CustomSideEffect({
    required this.type,
    required this.name,
  });

  final String name;
  final Type type;
}
