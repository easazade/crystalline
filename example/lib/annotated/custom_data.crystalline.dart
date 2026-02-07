// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field

part of 'custom_data.dart';

// Custom Data CustomData with custom operations: (DeleteUser, UpdateProfile)
class CustomDataOperation extends Operation {
  const CustomDataOperation(String name) : super(name);

  static const CustomDataOperation create = CustomDataOperation('create');
  static const CustomDataOperation read = CustomDataOperation('read');
  static const CustomDataOperation update = CustomDataOperation('update');
  static const CustomDataOperation delete = CustomDataOperation('delete');
  static const CustomDataOperation none = CustomDataOperation('none');
  // custom operations
  static const Operation deleteUser = Operation('DeleteUser');
  static const Operation updateProfile = Operation('UpdateProfile');
}

class CustomData extends Data<String> {
  CustomData({
    String? value,
    Failure? failure,
    CustomDataOperation operation = CustomDataOperation.none,
    Iterable<dynamic>? sideEffects,
    String? name,
  }) : super(
         value: value,
         failure: failure,
         operation: operation,
         sideEffects: sideEffects,
         name: name,
       );
}
