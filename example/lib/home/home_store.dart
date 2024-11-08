import 'package:flutter_crystalline/flutter_crystalline.dart';

final homeStore = HomeStore._();

class HomeStore extends Store {
  HomeStore._();

  final Data<String> title = Data(value: 'THIS TITLE');
  final Data<int> number = Data(value: 0);

  Future changeTitle() async {
    title.operation = Operation.operating;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    title.value = (title.value == 'THIS TITLE') ? 'THAT TITLE' : 'THIS TITLE';
    title.operation = Operation.none;
    notifyListeners();
  }

  Future changeNumber() async {
    final newValue = ++number.value;
    number.value = null;
    number.operation = Operation.update;
    failure = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    number.value = newValue;
    number.operation = Operation.none;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    failure = Failure('Some fake made failure');
  }

  @override
  List<Data<Object?>> get states => [title, number];

  @override
  String get storeName => 'HomeStore';
}
