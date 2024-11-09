import 'package:dart_mappable/dart_mappable.dart';

part 'cart_item.mapper.dart';

@MappableClass()
class CartItem with CartItemMappable {
  final int id;
  final String name;

  CartItem({
    required this.id,
    required this.name,
  });
}
