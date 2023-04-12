import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_crystalline/src/builders.dart';
import 'package:flutter_crystalline/src/when_builders.dart';

class BuildableData<T> extends Data<T> {
  BuildableData({super.value, super.error, super.operation});

  Widget build({
    required final DataWidgetBuilder<T> builder,
    bool listen = false,
  }) =>
      DataBuilder<T>(data: this, builder: builder, listen: listen);

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
    bool listen = false,
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
        listen: listen,
      );
}

class ChangeNotifierData<T> extends BuildableData<T>
    with ChangeNotifier
    implements ChangeNotifier {}
