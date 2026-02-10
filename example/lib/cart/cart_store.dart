import 'package:example/cart/models/cart_item.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

final cartStore = CartStore();

class CartStore extends Store {
  final cartItems = ListData<CartItem>([]);

  void addItem(CartItem item) {
    cartItems.add(Data(value: item));
    publish();
  }

  void deleteItem(CartItem item) {
    cartItems.removeWhere((e) => e.valueOrNull?.id == item.id);
    publish();
  }

  @override
  List<Data<Object?>> get states => [cartItems];
}
