import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/mutators/mutators.dart';

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

  factory OperationData.from(UnModifiableData<dynamic> data) {
    return data.mapTo(OperationData(), (origin, mutated) {
      mutated.error = origin.errorOrNull;
      mutated.operation = origin.operation;
      mutated.clearAllSideEffects();
      mutated.addAllSideEffects(origin.sideEffects);
    });
  }

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
