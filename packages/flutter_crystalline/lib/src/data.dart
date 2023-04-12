import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

class ChangeNotifierData<T> extends Data<T>
    with ChangeNotifier
    implements ChangeNotifier {}
