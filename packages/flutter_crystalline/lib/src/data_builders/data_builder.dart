import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';

class DataBuilder<T, D extends Data<T>> extends StatelessWidget {
  const DataBuilder({
    required this.data,
    required this.builder,
    super.key,
  });

  final D data;
  final Widget Function(BuildContext context, D data) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, data);
  }
}
