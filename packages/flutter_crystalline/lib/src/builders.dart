import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';

typedef DataWidgetBuilder<T, D extends Data<T>> = Widget Function(
  BuildContext context,
  D data,
);

class DataBuilder<T, D extends Data<T>> extends StatelessWidget {
  const DataBuilder({
    Key? key,
    required this.data,
    required this.builder,
    this.observe = false,
  }) : super(key: key);

  final D data;
  final bool observe;

  final Widget Function(BuildContext context, D data) builder;

  @override
  Widget build(BuildContext context) {
    if (observe) {
      return _DataRebuilder<T, D>(data: data, builder: builder);
    }
    return builder(context, data);
  }
}

class _DataRebuilder<T, D extends Data<T>> extends StatefulWidget {
  final D data;
  final Widget Function(BuildContext context, D data) builder;

  const _DataRebuilder({
    Key? key,
    required this.data,
    required this.builder,
  }) : super(key: key);

  @override
  State<_DataRebuilder<T, D>> createState() => _DataRebuilderState<T, D>();
}

class _DataRebuilderState<T, D extends Data<T>>
    extends State<_DataRebuilder<T, D>> {
  late D _data;

  late void Function() _observer = () => setState(() {});

  @override
  void initState() {
    _data = widget.data;
    _data.addObserver(_observer);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _DataRebuilder<T, D> oldWidget) {
    if (oldWidget.data != widget.data) {
      _data = widget.data;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data);
  }

  @override
  void dispose() {
    _data.removeObserver(_observer);
    super.dispose();
  }
}
