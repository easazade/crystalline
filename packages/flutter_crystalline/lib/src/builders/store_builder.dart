import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

class StoreBuilder<T extends Store> extends StatelessWidget {
  const StoreBuilder({
    super.key,
    required this.store,
    required this.builder,
    this.child,
  });

  final T store;
  final Widget? child;
  final Widget Function(BuildContext context, T store, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, child) => builder(context, store, child),
      child: child,
    );
  }
}
