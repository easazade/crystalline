import 'package:flutter_crystalline/flutter_crystalline.dart';

final profileStore = ProfileStore();

class ProfileStore extends Store {
  Future update() async {
    print('updating profile');

    operation = Operation.operating;
    failure = Failure('message');

    await Future.delayed(const Duration(seconds: 1));

    operation = Operation.none;
    failure = null;
  }

  @override
  List<Data<Object?>> get states => [];
}
