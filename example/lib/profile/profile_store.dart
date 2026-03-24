import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'profile_store.crystalline.dart';

final profileStore = ProfileStore();

@StoreClass()
abstract class _ProfileStore extends Store {
  final profileImage = Data<String>();

  Future update() async {
    operation = Operation.update;
    failure = Failure('This is an error message');
    profileImage.value = 'image url 1';

    await Future.delayed(const Duration(seconds: 3));

    profileImage.value = 'image url 2';
    operation = null;
    failure = null;
  }

  @override
  List<Data<Object?>> get states => [profileImage];
}
