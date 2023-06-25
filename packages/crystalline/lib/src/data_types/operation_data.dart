import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';

class OperationData extends Data<void> {
  OperationData({
    Operation operation = Operation.none,
    List<dynamic>? sideEffects,
    Failure? error,
  }) : super(
          operation: operation,
          sideEffects: sideEffects,
          error: error,
        );

  factory OperationData.from(ReadableData<dynamic> data) => OperationData(
        operation: data.operation,
        sideEffects: data.sideEffects,
        error: data.errorOrNull,
      )..updateFrom(data);

  @override
  void updateFrom(ReadableData<dynamic> data) {
    disallowNotifyObservers();
    operation = data.operation;
    error = data.errorOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects);
    allowNotifyObservers();
    notifyObservers();
  }

  @override
  OperationData copy() => OperationData(
        operation: operation,
        error: errorOrNull,
        sideEffects: sideEffects,
      );
}
