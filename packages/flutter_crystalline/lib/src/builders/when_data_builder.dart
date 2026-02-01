import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/src/typedefs.dart';

class WhenDataBuilder<T, D extends Data<T>> extends StatefulWidget {
  const WhenDataBuilder({
    super.key,
    required this.data,
    required this.onValue,
    this.onNoValue,
    this.onAnyOperation,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onRead,
    this.onFailure,
    this.orElse,
    this.fallback = const SizedBox(),
  });

  final D data;

  final DataWidgetBuilder<T, D> onValue;
  final DataWidgetBuilder<T, D>? onNoValue;

  final DataWidgetBuilder<T, D>? onAnyOperation;
  final DataWidgetBuilder<T, D>? onCreate;
  final DataWidgetBuilder<T, D>? onDelete;
  final DataWidgetBuilder<T, D>? onRead;
  final DataWidgetBuilder<T, D>? onUpdate;

  final DataWidgetBuilder<T, D>? onFailure;
  final DataWidgetBuilder<T, D>? orElse;

  final Widget fallback;

  @override
  State<WhenDataBuilder<T, D>> createState() => _WhenDataBuilderState<T, D>();
}

class _WhenDataBuilderState<T, D extends Data<T>> extends State<WhenDataBuilder<T, D>> {
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
  void didUpdateWidget(covariant WhenDataBuilder<T, D> oldWidget) {
    if (!identical(oldWidget.data, widget.data)) {
      oldWidget.data.removeObserver(_observer);
      _data = widget.data;
      _data.addObserver(_observer);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isCreating && widget.onCreate != null) {
      return widget.onCreate!(context, _data);
    }
    if (_data.isDeleting && widget.onDelete != null) {
      return widget.onDelete!(context, _data);
    }
    if (_data.isReading && widget.onRead != null) {
      return widget.onRead!(context, _data);
    }
    if (_data.isUpdating && widget.onUpdate != null) {
      return widget.onUpdate!(context, _data);
    }
    if (_data.isAnyOperation && widget.onAnyOperation != null) {
      return widget.onAnyOperation!(context, _data);
    }
    if (_data.hasFailure && widget.onFailure != null) {
      return widget.onFailure!(context, _data);
    }
    if (_data.hasValue) {
      return widget.onValue(context, _data);
    }
    if (_data.hasNoValue && widget.onNoValue != null) {
      return widget.onNoValue!(context, _data);
    }
    return (widget.orElse != null) ? widget.orElse!(context, _data) : widget.fallback;
  }

  @override
  void dispose() {
    _data.removeObserver(_observer);
    super.dispose();
  }
}
