import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';

class DataBuilder<T, D extends Data<T>> extends StatefulWidget {
  final D data;
  final Widget Function(BuildContext context, D data) builder;

  const DataBuilder({
    super.key,
    required this.data,
    required this.builder,
  });

  @override
  State<DataBuilder<T, D>> createState() => DataBuilderState<T, D>();
}

class DataBuilderState<T, D extends Data<T>> extends State<DataBuilder<T, D>> {
  late D _data;

  void _observer() {
    setState(() {});
  }

  @override
  void initState() {
    _data = widget.data;
    _data.addObserver(_observer);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DataBuilder<T, D> oldWidget) {
    if (!identical(oldWidget.data, widget.data)) {
      _data = widget.data;
      oldWidget.data.removeObserver(_observer);
      widget.data.addObserver(_observer);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _data);

  @override
  void dispose() {
    _data.removeObserver(_observer);
    super.dispose();
  }
}
