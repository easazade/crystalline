import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class ChangeNotifierData extends CollectionData
    with ChangeNotifier
    implements ChangeNotifier {
  @override
  void addListener(void Function() listener) {
    requiredItems?.forEach((item) {
      print('adding listener');
      item.addListener(listener);
    });
  }

  @override
  void removeListener(void Function() listener) {
    requiredItems?.forEach((item) {
      print('removing listener');
      item.removeListener(listener);
    });
  }
}
