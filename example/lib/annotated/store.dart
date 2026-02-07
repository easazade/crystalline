import 'package:flutter_crystalline/annotations.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'store.crystalline.dart';

@store()
abstract class _GeneralStore extends Store {
  final user = Data<String>();
}

awD() {
  GeneralStore().addListener(() {});
}
