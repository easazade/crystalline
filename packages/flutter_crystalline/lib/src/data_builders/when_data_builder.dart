import 'package:crystalline/crystalline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/src/typedefs.dart';

class WhenDataBuilder<T, D extends Data<T>> extends StatelessWidget {
  const WhenDataBuilder({
    super.key,
    required this.data,
    required this.onValue,
    this.onNoValue,
    this.onUpdate,
    this.onCreate,
    this.onDelete,
    this.onFetch,
    this.onAnyOperation,
    this.onFailure,
    this.orElse,
    this.fallback = const SizedBox(),
  });

  final D data;

  final DataWidgetBuilder<T, D> onValue;
  final DataWidgetBuilder<T, D>? onNoValue;

  final DataWidgetBuilder<T, D>? onCreate;
  final DataWidgetBuilder<T, D>? onDelete;
  final DataWidgetBuilder<T, D>? onFetch;
  final DataWidgetBuilder<T, D>? onUpdate;
  final DataWidgetBuilder<T, D>? onAnyOperation;

  final DataWidgetBuilder<T, D>? onFailure;

  /// called when there is no corresponding builder method for
  /// the given status (operation/value/failure)
  final DataWidgetBuilder<T, D>? orElse;

  final Widget fallback;

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
    if (data.isAnyOperation && onAnyOperation != null) {
      return onAnyOperation!(context, data);
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
