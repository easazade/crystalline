import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';

typedef DataWidgetBuilder<T, D extends Data<T>> = Widget Function(
  BuildContext context,
  D data,
);