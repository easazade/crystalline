import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

typedef Store = ChangeNotifierData;

abstract class ChangeNotifierData extends CollectionData<Object?>
    with ChangeNotifier {}
