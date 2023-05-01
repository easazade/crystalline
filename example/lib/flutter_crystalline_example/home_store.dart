import 'package:flutter_crystalline/flutter_crystalline.dart';

final homeStore = HomeStore._();

class HomeStore extends ChangeNotifierData {
  HomeStore._();

  final Data<String> title = Data(value: 'THIS TITLE');
  final Data<int> number = Data(value: 0);

  Future changeTitle() async {
    title.operation = Operation.loading;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    title.value = (title.value == 'THIS TITLE') ? 'THAT TITLE' : 'THIS TITLE';
    title.operation = Operation.none;
    notifyListeners();
  }

  Future changeNumber() async {
    number.operation = Operation.update;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    number.value = number.value + 1;
    number.operation = Operation.none;
    notifyListeners();
  }
}
