// ignore_for_file: unused_element_parameter

import 'package:example/cart/models/cart_item.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'store.crystalline.dart';

@StoreClass()
abstract class _GeneralStore extends Store {
  _GeneralStore(this.key, {required this.token, this.degree, this.withDefault = true});

  final String key;
  final int token;
  final double? degree;
  final bool withDefault;

  @SharedData()
  Data<CartItem> get cartItem;

  final user = Data<String>();
  final ope = OperationData();
}
