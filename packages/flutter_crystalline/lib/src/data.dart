import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class ChangeNotifierData extends DataCollection
    with ChangeNotifier
    implements ChangeNotifier {}
