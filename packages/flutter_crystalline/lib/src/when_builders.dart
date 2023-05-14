import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/src/builders.dart';

class WhenDataBuilder<T, D extends Data<T>> extends StatelessWidget {
  const WhenDataBuilder({
    super.key,
    required this.data,
    required this.onValue,
    this.onNoValue,
    this.onLoading,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onError,
    this.orElse,
    this.observe = false,
    this.fallback = const SizedBox(),
  });

  final D data;

  final DataWidgetBuilder<T, D> onValue;
  final DataWidgetBuilder<T, D>? onNoValue;

  final DataWidgetBuilder<T, D>? onLoading;
  final DataWidgetBuilder<T, D>? onCreate;
  final DataWidgetBuilder<T, D>? onDelete;
  final DataWidgetBuilder<T, D>? onFetch;
  final DataWidgetBuilder<T, D>? onUpdate;

  final DataWidgetBuilder<T, D>? onError;
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
        onLoading: onLoading,
        onUpdate: onUpdate,
        onCreate: onCreate,
        onDelete: onDelete,
        onFetch: onFetch,
        onError: onError,
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
    if (data.isLoading && onLoading != null) {
      return onLoading!(context, data);
    }
    if (data.hasError && onError != null) {
      return onError!(context, data);
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
    this.onLoading,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onError,
    this.orElse,
    this.fallback = const SizedBox(),
  });

  final D data;

  final DataWidgetBuilder<T, D> onValue;
  final DataWidgetBuilder<T, D>? onNoValue;

  final DataWidgetBuilder<T, D>? onLoading;
  final DataWidgetBuilder<T, D>? onCreate;
  final DataWidgetBuilder<T, D>? onDelete;
  final DataWidgetBuilder<T, D>? onFetch;
  final DataWidgetBuilder<T, D>? onUpdate;

  final DataWidgetBuilder<T, D>? onError;
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
    if (oldWidget.data != widget.data) {
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
    if (_data.isLoading && widget.onLoading != null) {
      return widget.onLoading!(context, _data);
    }
    if (_data.hasError && widget.onError != null) {
      return widget.onError!(context, _data);
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
