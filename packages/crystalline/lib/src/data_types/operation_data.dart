import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';

class OperationData extends Data<void> {
  OperationData({
    Failure? error,
    Operation operation = Operation.none,
    List<dynamic>? sideEffects,
  }) : super(
          error: error,
          operation: operation,
          sideEffects: sideEffects,
        );

  @override
  void updateFrom(ReadableData<dynamic> data) {
    disallowNotifyObservers();
    operation = data.operation;
    error = data.errorOrNull;
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
