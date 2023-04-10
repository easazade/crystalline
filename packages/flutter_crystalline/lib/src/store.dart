
import 'package:crystalline/crystalline.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/src/builders.dart';
import 'package:flutter_crystalline/src/store_consumer.dart';

abstract class Store<T extends BaseStore> extends BaseStore with EquatableMixin implements ReadableData<T> {
  DataError? _error;
  Operation _operation = Operation.none;

  @override
  T get value => this as T;

  @override
  DataError get consumeError {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    DataError consumedErrorValue = _error!;
    _error = null;
    return consumedErrorValue;
  }

  @override
  DataError get error {
    if (_error == null) {
      throw DataErrorIsNullException();
    }
    return _error!;
  }

  @override
  bool get hasError => _error != null;

  @override
  bool get isAvailable;

  @override
  List<Object?> get props;

  @override
  bool get isNotAvailable => !isAvailable;

  @override
  bool get isCreating => _operation == Operation.create;

  @override
  bool get isDeleting => _operation == Operation.delete;

  @override
  bool get isFetching => _operation == Operation.fetch;

  @override
  bool get isUpdating => _operation == Operation.update;

  @override
  bool get isLoading => _operation != Operation.none;

  @override
  bool valueEqualsTo(T? otherValue) => this == otherValue;

  void setStoreError(DataError? error) {
    _error = error;
  }

  void setStoreOperation(Operation operation) {
    _operation = operation;
  }

  Widget consume({
    required StoreWidgetBuilder<T> builder,
    final void Function(BuildContext context, T store)? listener,
  }) => StoreConsumer(
      listener: listener,
      store: this as T,
      builder: builder,
    );

  Widget consumeWhen({
    required StoreWidgetBuilder<T> onAvailable,
    void Function(BuildContext context, T store)? listener,
    StoreWidgetBuilder<T>? onNotAvailable,
    StoreWidgetBuilder<T>? onLoading,
    StoreWidgetBuilder<T>? onCreate,
    StoreWidgetBuilder<T>? onDelete,
    StoreWidgetBuilder<T>? onFetch,
    StoreWidgetBuilder<T>? onUpdate,
    StoreWidgetBuilder<T>? onError,
    StoreWidgetBuilder<T>? orElse,
  }) => StoreConsumer(
      store: this as T,
      listener: listener,
      builder: (context, store) {
        return WhenStoreBuilder<T>(
          readableData: this,
          value: this as T,
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
      },
    );

  @override
  String toString() => '$runtimeType : operation: $_operation - error: $_error';
}

class BaseStore extends ChangeNotifier {
  final storeId = StoreId();
  void updateStore() => notifyListeners();
}

/// an object that only equals to itslef just like Flutter UniqueKey()
class StoreId {
  @override
  String toString() => '[#${_shortHash(this)}]';
}

String _shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}
