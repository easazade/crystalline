import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class ChangeNotifierData extends CollectionData
    with ChangeNotifier
    implements ChangeNotifier {}
