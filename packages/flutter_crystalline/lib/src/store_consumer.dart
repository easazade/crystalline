import 'package:flutter/material.dart';
import 'package:flutter_crystalline/src/store.dart';

class StoreConsumer<T extends BaseStore> extends StatefulWidget {
  final T store;
  // final T Function(BuildContext context)? lazyStore;
  final void Function(BuildContext context, T store)? listener;
  final Widget Function(BuildContext context, T store) builder;

  const StoreConsumer({
    Key? key,
    required this.store,
    required this.builder,
    this.listener,
  }) : super(key: key);

  @override
  State<StoreConsumer<T>> createState() => _State<T>();
}

class _State<T extends BaseStore> extends State<StoreConsumer<T>> {
  late void Function() _listener;

  late T _store;

  @override
  void initState() {
    _store = widget.store;
    _listener = () => setState(() {});
    _store.addListener(_listener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StoreConsumer<T> oldWidget) {
    if (oldWidget.store.storeId != widget.store.storeId) {
      _store = widget.store;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    widget.listener?.call(context, _store);
    return widget.builder(context, _store);
  }

  @override
  void dispose() {
    _store.removeListener(_listener);
    super.dispose();
  }
}
