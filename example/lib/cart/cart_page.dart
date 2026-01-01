import 'package:example/cart/cart_store.dart';
import 'package:example/cart/models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _controller = TextEditingController();
  int _lastGeneratedId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: StoreBuilder(
        store: cartStore,
        builder: (context, store, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter shopping item name to add it to cart',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final itemName = _controller.text;
                  if (itemName.trim().isNotEmpty) {
                    _controller.clear();
                    store.addItem(
                      CartItem(id: _generateId(), name: itemName),
                    );
                  }
                },
                child: const Text('Add to Cart'),
              ),
              if (store.cartItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
              ],
              const SizedBox(height: 16),
              for (final cartItem in store.cartItems)
                if (cartItem.hasValue)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cartItem.value.name,
                          style: const TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: () => store.deleteItem(cartItem.value),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
            ],
          );
        },
      ),
    );
  }

  int _generateId() {
    _lastGeneratedId += 1;
    return _lastGeneratedId;
  }
}
