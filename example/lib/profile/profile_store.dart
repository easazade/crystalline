import 'package:flutter_crystalline/flutter_crystalline.dart';

final profileStore = ProfileStore();

class ProfileStore extends Store {
  final profileImage = Data<String>();

  Future update() async {
    print('updating profile');
    print(this);

    operation = Operation.operating;
    failure = Failure('This is an error message');
    print(this);

    await Future.delayed(const Duration(seconds: 8));

    operation = Operation.none;
    failure = null;
  }

  @override
  List<Data<Object?>> get states => [];
}
