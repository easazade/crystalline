import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';

typedef DataWidgetBuilder<T> = Widget Function(
  BuildContext context,
  ReadableData<T> data,
);

typedef StoreWidgetBuilder<T> = Widget Function(BuildContext context, T store);

class DataBuilder<T> extends StatelessWidget {
  const DataBuilder({
    Key? key,
    required this.data,
    required this.builder,
  }) : super(key: key);

  final ReadableData<T> data;

  final Widget Function(BuildContext context, ReadableData<T> data) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, data);
  }
}

class WhenDataBuilder<T> extends StatelessWidget {
  const WhenDataBuilder({
    Key? key,
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
  }) : super(key: key);

  final ReadableData<T> data;

  final DataWidgetBuilder<T> onAvailable;
  final DataWidgetBuilder<T>? onNotAvailable;

  final DataWidgetBuilder<T>? onLoading;
  final DataWidgetBuilder<T>? onCreate;
  final DataWidgetBuilder<T>? onDelete;
  final DataWidgetBuilder<T>? onFetch;
  final DataWidgetBuilder<T>? onUpdate;

  final DataWidgetBuilder<T>? onError;
  final DataWidgetBuilder<T>? orElse;

  @override
  Widget build(BuildContext context) {
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
    return (orElse != null) ? orElse!(context, data) : Container();
  }
}

class WhenStoreBuilder<T> extends StatelessWidget {
  const WhenStoreBuilder({
    Key? key,
    required this.readableData,
    required this.value,
    required this.onAvailable,
    this.onNotAvailable,
    this.onLoading,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onError,
    this.orElse,
  }) : super(key: key);

  final T value;
  final ReadableData<T> readableData;

  final StoreWidgetBuilder<T> onAvailable;
  final StoreWidgetBuilder<T>? onNotAvailable;

  final StoreWidgetBuilder<T>? onLoading;
  final StoreWidgetBuilder<T>? onCreate;
  final StoreWidgetBuilder<T>? onDelete;
  final StoreWidgetBuilder<T>? onFetch;
  final StoreWidgetBuilder<T>? onUpdate;

  final StoreWidgetBuilder<T>? onError;
  final StoreWidgetBuilder<T>? orElse;

  @override
  Widget build(BuildContext context) {
    if (readableData.isCreating && onCreate != null) {
      return onCreate!(context, value);
    }
    if (readableData.isDeleting && onDelete != null) {
      return onDelete!(context, value);
    }
    if (readableData.isFetching && onFetch != null) {
      return onFetch!(context, value);
    }
    if (readableData.isUpdating && onUpdate != null) {
      return onUpdate!(context, value);
    }
    if (readableData.isLoading && onLoading != null) {
      return onLoading!(context, value);
    }
    if (readableData.hasError && onError != null) {
      return onError!(context, value);
    }
    if (readableData.isAvailable) {
      return onAvailable(context, value);
    }
    if (readableData.isNotAvailable && onNotAvailable != null) {
      return onNotAvailable!(context, value);
    }
    return (orElse != null) ? orElse!(context, value) : Container();
  }
}
