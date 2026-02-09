// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

part of 'store.dart';

final $$cartItemSharedProperty = Data<CartItem>();

class GeneralStore extends _GeneralStore with _GeneralStoreMixin {
  // constructor
  GeneralStore(
    super.key, {
    required super.token,
    super.degree,
    super.withDefault = true,
  });

  @override
  final cartItem = $$cartItemSharedProperty;
}

mixin _GeneralStoreMixin on _GeneralStore {
  @override
  List<Data<Object?>> get states => [cartItem, user, ope];

  @override
  String? get name => 'GeneralStore';
}
