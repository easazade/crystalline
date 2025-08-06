import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';

class DataBinder<T, D extends Data<T>> extends StatefulWidget {
  final D data;
  final Widget Function(BuildContext context, D data) builder;

  const DataBinder({
    Key? key,
    required this.data,
    required this.builder,
  }) : super(key: key);

  @override
  State<DataBinder<T, D>> createState() => DataBinderState<T, D>();
}

class DataBinderState<T, D extends Data<T>> extends State<DataBinder<T, D>> {
  late D _data;

  late void Function() _observer = () => setState(() {});

  @override
  void initState() {
    _data = widget.data;
    _data.addObserver(_observer);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DataBinder<T, D> oldWidget) {
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
