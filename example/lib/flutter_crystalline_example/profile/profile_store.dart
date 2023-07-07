import 'package:flutter_crystalline/flutter_crystalline.dart';

final profileStore = ProfileStore();

class ProfileStore extends ChangeNotifierData {
  Future update() async {
    print('updating profile');

    operation = Operation.operating;
    error = Failure('message');

    await Future.delayed(const Duration(seconds: 1));

    operation = Operation.none;
    error = null;
  }

  @override
  List<Data<Object?>> get items => [];
}
