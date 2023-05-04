import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/src/builders.dart';

class WhenDataBuilder<T> extends StatelessWidget {
  const WhenDataBuilder({
    super.key,
    required this.data,
    required this.onAvailable,
    this.onNotAvailable,
    this.onLoading,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onError,
    this.orElse,
    this.listen = false,
    this.fallback = const SizedBox(),
  });

  final Data<T> data;

  final DataWidgetBuilder<T> onAvailable;
  final DataWidgetBuilder<T>? onNotAvailable;

  final DataWidgetBuilder<T>? onLoading;
  final DataWidgetBuilder<T>? onCreate;
  final DataWidgetBuilder<T>? onDelete;
  final DataWidgetBuilder<T>? onFetch;
  final DataWidgetBuilder<T>? onUpdate;

  final DataWidgetBuilder<T>? onError;
  final DataWidgetBuilder<T>? orElse;

  final Widget fallback;

  final bool listen;

  @override
  Widget build(BuildContext context) {
    if (listen) {
      return _WhenDataRebuilder(
        data: data,
        onAvailable: onAvailable,
        onNotAvailable: onNotAvailable,
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
    if (data.isAvailable) {
      return onAvailable(context, data);
    }
    if (data.isNotAvailable && onNotAvailable != null) {
      return onNotAvailable!(context, data);
    }
    return (orElse != null) ? orElse!(context, data) : fallback;
  }
}

class _WhenDataRebuilder<T> extends StatefulWidget {
  const _WhenDataRebuilder({
    super.key,
    required this.data,
    required this.onAvailable,
    this.onNotAvailable,
    this.onLoading,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onError,
    this.orElse,
    this.fallback = const SizedBox(),
  });

  final Data<T> data;

  final DataWidgetBuilder<T> onAvailable;
  final DataWidgetBuilder<T>? onNotAvailable;

  final DataWidgetBuilder<T>? onLoading;
  final DataWidgetBuilder<T>? onCreate;
  final DataWidgetBuilder<T>? onDelete;
  final DataWidgetBuilder<T>? onFetch;
  final DataWidgetBuilder<T>? onUpdate;

  final DataWidgetBuilder<T>? onError;
  final DataWidgetBuilder<T>? orElse;

  final Widget fallback;

  @override
  State<_WhenDataRebuilder<T>> createState() => _WhenDataRebuilderState<T>();
}

class _WhenDataRebuilderState<T> extends State<_WhenDataRebuilder<T>> {
  late Data<T> _data;

  late void Function() _observer = () => setState(() {});

  @override
  void initState() {
    _data = widget.data;
    _data.addObserver(_observer);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _WhenDataRebuilder<T> oldWidget) {
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
    if (_data.isAvailable) {
      return widget.onAvailable(context, _data);
    }
    if (_data.isNotAvailable && widget.onNotAvailable != null) {
      return widget.onNotAvailable!(context, _data);
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
