import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

class StoreBuilder<T extends Store> extends StatefulWidget {
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
  State<StoreBuilder<T>> createState() => _State<T>();
}

class _State<T extends Store> extends State<StoreBuilder<T>> {
  late T _store;

  late final _observer = Observer(() {
    setState(() {});
  });

  @override
  void initState() {
    _store = widget.store;
    _store.observers.add(_observer);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StoreBuilder<T> oldWidget) {
    if (!identical(oldWidget.store, widget.store)) {
      _store = widget.store;
      oldWidget.store.observers.remove(_observer);
      widget.store.observers.add(_observer);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _store, widget.child);

  @override
  void dispose() {
    _store.observers.remove(_observer);
    super.dispose();
  }
}
