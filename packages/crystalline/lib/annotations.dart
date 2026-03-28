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
  const FormPageInfo({required this.name, required this.items});

  final String name;
  final List<InputDataInfo> items;
}

class FormClass {
  const FormClass({required this.name, required this.pages});

  final String name;
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
