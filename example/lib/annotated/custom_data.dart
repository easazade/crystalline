// ignore_for_file: unused_element

import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'custom_data.crystalline.dart';

@DataClass(
  valueType: String,
  customOperations: ['DeleteUser', 'UpdateProfile'],
)
class _CustomData {}
