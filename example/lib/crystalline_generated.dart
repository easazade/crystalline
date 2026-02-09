// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

import 'package:flutter_crystalline/flutter_crystalline.dart';

import 'package:example/annotated/store.dart';
import 'package:example/cart/models/cart_item.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'dart:core';

class SharedState {
  static SharedState? _instance;
  static SharedState get instance {
    if (_instance == null) {
      _instance = SharedState();
    }

    return _instance!;
  }

  final cartItem = $$cartItemSharedProperty;
}
