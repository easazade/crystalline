import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

class ChangeNotifierData extends Data<dynamic>
    with ChangeNotifier
    implements ChangeNotifier {
  ChangeNotifierData() {
    // OH THIS IS BAD AND SHOULD BE CHANGED.
    value = this;
  }
}
