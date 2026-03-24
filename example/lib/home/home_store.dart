import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'home_store.crystalline.dart';

final homeStore = HomeStore();

@StoreClass()
abstract class _HomeStore extends Store {
  final Data<String> title = Data(value: 'THIS TITLE');
  final Data<int> number = Data(value: 0);

  Future changeTitle() async {
    title.operation = Operation.update;
    publish();

    await Future.delayed(const Duration(seconds: 1));
    title.value = (title.value == 'THIS TITLE') ? 'THAT TITLE' : 'THIS TITLE';
    title.operation = null;
    publish();
  }

  Future changeNumber() async {
    final newValue = ++number.value;
    number.value = null;
    number.operation = Operation.update;
    failure = null;
    publish();

    await Future.delayed(const Duration(seconds: 1));
    number.value = newValue;
    number.operation = null;
    publish();

    await Future.delayed(const Duration(seconds: 1));
    failure = Failure('Some fake made failure');
  }

  @override
  List<Data<Object?>> get states => [title, number];
}
