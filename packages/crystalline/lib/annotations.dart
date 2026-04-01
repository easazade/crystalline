class StoreClass {
  const StoreClass();
}

class InputDataInfo {
  const InputDataInfo({required this.name, required this.inputType, required this.valueType});

  final String name;
  final Type inputType;
  final Type valueType;
}

class FormPageInfo {
  const FormPageInfo({required this.name, required this.items, required this.submitResultType});

  final String name;
  final List<InputDataInfo> items;
  final Type submitResultType;
}

class FormClass {
  const FormClass({required this.pages});

  final List<FormPageInfo> pages;
}

class SharedData {
  const SharedData();
}

class CustomSideEffect {
  const CustomSideEffect({required this.type, required this.name});

  final String name;
  final Type type;
}
