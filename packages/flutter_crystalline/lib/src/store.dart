import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';


abstract class Store extends CollectionData<Object?>
    with ChangeNotifier {
  @override
  List<Data<Object?>> get items => states;

  List<Data<Object?>> get states;
}
