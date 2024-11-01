import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/src/builders/builders.dart';

class WhenDataBuilder<T, D extends Data<T>> extends StatelessWidget {
  const WhenDataBuilder({
    super.key,
    required this.data,
    required this.onValue,
    this.onNoValue,
    this.onOperate,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onCustomOperation,
    this.onFailure,
    this.orElse,
    this.observe = false,
    this.fallback = const SizedBox(),
  });

  final D data;

  final DataWidgetBuilder<T, D> onValue;
  final DataWidgetBuilder<T, D>? onNoValue;

  final DataWidgetBuilder<T, D>? onOperate;
  final DataWidgetBuilder<T, D>? onCreate;
  final DataWidgetBuilder<T, D>? onDelete;
  final DataWidgetBuilder<T, D>? onFetch;
  final DataWidgetBuilder<T, D>? onUpdate;
  final DataWidgetBuilder<T, D>? onCustomOperation;

  final DataWidgetBuilder<T, D>? onFailure;

  /// called when there is no corresponding builder method for
  /// the given status (operation/value/failure)
  final DataWidgetBuilder<T, D>? orElse;

  final Widget fallback;

  final bool observe;

  @override
  Widget build(BuildContext context) {
    if (observe) {
      return _WhenDataRebuilder<T, D>(
        data: data,
        onValue: onValue,
        onNoValue: onNoValue,
        onOperate: onOperate,
        onUpdate: onUpdate,
        onCreate: onCreate,
        onDelete: onDelete,
        onFetch: onFetch,
        onCustomOperation: onCustomOperation,
        onFailure: onFailure,
        orElse: orElse,
        fallback: fallback,
      );
    }

    if (data.isCreating && onCreate != null) {
      return onCreate!(context, data);
    }
    if (data.isDeleting && onDelete != null) {
      return onDelete!(context, data);
    }
    if (data.isFetching && onFetch != null) {
      return onFetch!(context, data);
    }
    if (data.isUpdating && onUpdate != null) {
      return onUpdate!(context, data);
    }
    if (data.hasCustomOperation && onCustomOperation != null) {
      return onCustomOperation!(context, data);
    }
    if (data.isOperating && onOperate != null) {
      return onOperate!(context, data);
    }
    if (data.hasFailure && onFailure != null) {
      return onFailure!(context, data);
    }
    if (data.hasValue) {
      return onValue(context, data);
    }
    if (data.hasNoValue && onNoValue != null) {
      return onNoValue!(context, data);
    }
    return (orElse != null) ? orElse!(context, data) : fallback;
  }
}

class _WhenDataRebuilder<T, D extends Data<T>> extends StatefulWidget {
  const _WhenDataRebuilder({
    super.key,
    required this.data,
    required this.onValue,
    this.onNoValue,
    this.onOperate,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onCustomOperation,
    this.onFailure,
    this.orElse,
    this.fallback = const SizedBox(),
  });

  final D data;

  final DataWidgetBuilder<T, D> onValue;
  final DataWidgetBuilder<T, D>? onNoValue;

  final DataWidgetBuilder<T, D>? onOperate;
  final DataWidgetBuilder<T, D>? onCreate;
  final DataWidgetBuilder<T, D>? onDelete;
  final DataWidgetBuilder<T, D>? onFetch;
  final DataWidgetBuilder<T, D>? onUpdate;
  final DataWidgetBuilder<T, D>? onCustomOperation;

  final DataWidgetBuilder<T, D>? onFailure;
  final DataWidgetBuilder<T, D>? orElse;

  final Widget fallback;

  @override
  State<_WhenDataRebuilder<T, D>> createState() =>
      _WhenDataRebuilderState<T, D>();
}

class _WhenDataRebuilderState<T, D extends Data<T>>
    extends State<_WhenDataRebuilder<T, D>> {
  late D _data;

  late void Function() _observer = () => setState(() {});

  @override
  void initState() {
    _data = widget.data;
    _data.addObserver(_observer);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _WhenDataRebuilder<T, D> oldWidget) {
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
    if (_data.isFetching && widget.onFetch != null) {
      return widget.onFetch!(context, _data);
    }
    if (_data.isUpdating && widget.onUpdate != null) {
      return widget.onUpdate!(context, _data);
    }
    if (_data.hasCustomOperation && widget.onCustomOperation != null) {
      return widget.onCustomOperation!(context, _data);
    }
    if (_data.isOperating && widget.onOperate != null) {
      return widget.onOperate!(context, _data);
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
    return (widget.orElse != null)
        ? widget.orElse!(context, _data)
        : widget.fallback;
  }

  @override
  void dispose() {
    _data.removeObserver(_observer);
    super.dispose();
  }
}
