import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';

typedef DataWidgetBuilder<T> = Widget Function(
  BuildContext context,
  Data<T> data,
);

class DataBuilder<T> extends StatelessWidget {
  const DataBuilder({
    Key? key,
    required this.data,
    required this.builder,
    this.listen = false,
  }) : super(key: key);

  final Data<T> data;
  final bool listen;

  final Widget Function(BuildContext context, Data<T> data) builder;

  @override
  Widget build(BuildContext context) {
    if (listen) {
      return _DataRebuilder<T>(data: data, builder: builder);
    }
    return builder(context, data);
  }
}

class _DataRebuilder<T> extends StatefulWidget {
  final Data<T> data;
  // final T Function(BuildContext context)? lazyStore;
  final void Function(BuildContext context, Data<T> data)? listener;
  final Widget Function(BuildContext context, Data<T> data) builder;

  const _DataRebuilder({
    Key? key,
    required this.data,
    required this.builder,
    this.listener,
  }) : super(key: key);

  @override
  State<_DataRebuilder<T>> createState() => _DataRebuilderState<T>();
}

class _DataRebuilderState<T> extends State<_DataRebuilder<T>> {
  late Data<T> _data;

  late void Function() _listener = () => setState(() {});

  @override
  void initState() {
    _data = widget.data;
    _data.addListener(_listener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _DataRebuilder<T> oldWidget) {
    if (oldWidget.data != widget.data) {
      _data = widget.data;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: no listener is being passed here. classes that use this class
    // TODO: is this the right place to call listener?
    widget.listener?.call(context, _data);
    return widget.builder(context, _data);
  }

  @override
  void dispose() {
    _data.removeListener(_listener);
    super.dispose();
  }
}
