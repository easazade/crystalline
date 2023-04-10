import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_crystalline/src/builders.dart';

class BuildableData<T> extends Data<T> implements ReadableData<T>, EditableData<T> {
  BuildableData({super.value, super.error, super.operation});

  Widget build(final DataWidgetBuilder<T> builder) => DataBuilder<T>(data: this, builder: builder);

  Widget buildWhen({
    required DataWidgetBuilder<T> onAvailable,
    DataWidgetBuilder<T>? onNotAvailable,
    DataWidgetBuilder<T>? onLoading,
    DataWidgetBuilder<T>? onCreate,
    DataWidgetBuilder<T>? onDelete,
    DataWidgetBuilder<T>? onFetch,
    DataWidgetBuilder<T>? onUpdate,
    DataWidgetBuilder<T>? onError,
    DataWidgetBuilder<T>? orElse,
  }) =>
      WhenDataBuilder<T>(
        data: this,
        onAvailable: onAvailable,
        onNotAvailable: onNotAvailable,
        onLoading: onLoading,
        onCreate: onCreate,
        onDelete: onDelete,
        onFetch: onFetch,
        onUpdate: onUpdate,
        onError: onError,
        orElse: orElse,
      );
}
