import 'package:flutter_crystalline/flutter_crystalline.dart';

final profileStore = ProfileStore();

class ProfileStore extends Store {
  final profileImage = Data<String>();

  Future update() async {
    operation = Operation.operating;
    failure = Failure('This is an error message');
    profileImage.value = 'image url 1';

    await Future.delayed(const Duration(seconds: 3));

    profileImage.value = 'image url 2';
    operation = Operation.none;
    failure = null;
  }

  @override
  List<Data<Object?>> get states => [profileImage];

  @override
  String get storeName => 'ProfileStore';
}
