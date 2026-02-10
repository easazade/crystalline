// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

part of 'store.dart';

final $$cartItemSharedProperty = Data<CartItem>();

class GeneralStore extends _GeneralStore {
  // constructor
  GeneralStore(
    super.key, {
    required super.token,
    super.degree,
    super.withDefault = true,
  });

  @override
  final cartItem = $$cartItemSharedProperty;

  @override
  List<Data<Object?>> get states => [cartItem, user, ope];

  @override
  String? get name => 'GeneralStore';

  @override
  bool operator ==(Object other) {
    if (other is! GeneralStore) return false;

    return other.runtimeType == runtimeType &&
        failureOrNull == other.failureOrNull &&
        operation == other.operation &&
        const ListEquality().equals(
          sideEffects.all.toList(),
          other.sideEffects.all.toList(),
        ) &&
        const ListEquality().equals(states, other.states);
  }

  @override
  int get hashCode =>
      (failureOrNull?.hashCode ?? 9) +
      sideEffects.all.hashCode +
      states.hashCode +
      operation.hashCode +
      runtimeType.hashCode;

  @override
  Stream<GeneralStore> get stream => streamController.stream.map((e) => this);
}
