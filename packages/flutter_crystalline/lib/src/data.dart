import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class ChangeNotifierData extends CollectionData
    with ChangeNotifier
    implements ChangeNotifier {
  @override
  void addObserver(void Function() observer) {
    requiredItems?.forEach((item) {
      item.addObserver(observer);
    });
  }

  @override
  void removeObserver(void Function() observer) {
    requiredItems?.forEach((item) {
      item.removeObserver(observer);
    });
  }
}
