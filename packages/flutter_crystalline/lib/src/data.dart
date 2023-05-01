import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

class ChangeNotifierData extends Data<dynamic>
    with ChangeNotifier
    implements ChangeNotifier {
  ChangeNotifierData() {
    value = this;
  }
}
