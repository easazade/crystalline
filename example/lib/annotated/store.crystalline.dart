// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field

part of 'store.dart';

class GeneralStore extends _GeneralStore with _GeneralStoreMixin {
  // constructor
  GeneralStore(
    super.key, {
    required super.token,
    super.degree,
    super.withDefault = true,
  });
}

mixin _GeneralStoreMixin on _GeneralStore {
  @override
  List<Data<Object?>> get states => [user, ope];

  @override
  String? get name => 'GeneralStore';
}
