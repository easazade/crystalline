// ignore_for_file: unused_element_parameter

import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'store.crystalline.dart';

@store()
abstract class _GeneralStore extends Store {
  _GeneralStore(this.key, {required this.token, this.degree, this.withDefault = true});

  final String key;
  final int token;
  final double? degree;
  final bool withDefault;

  final user = Data<String>();
  final ope = OperationData();
}
