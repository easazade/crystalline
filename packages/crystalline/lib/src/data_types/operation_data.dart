import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/mutators/mutators.dart';

class OperationData extends Data<void> {
  OperationData({
    Operation operation = Operation.none,
    Iterable<dynamic>? sideEffects,
    Failure? failure,
  }) : super(
          operation: operation,
          sideEffects: sideEffects,
          failure: failure,
        );

  factory OperationData.from(Data<dynamic> data) {
    return data.mapTo<dynamic, OperationData>(OperationData(),
        (origin, mutated) {
      mutated.failure = origin.failureOrNull;
      mutated.operation = origin.operation;
      mutated.clearAllSideEffects();
      mutated.addAllSideEffects(origin.sideEffects);
    });
  }

  @override
  void updateFrom(ReadableData<dynamic> data) {
    disallowNotify();
    operation = data.operation;
    failure = data.failureOrNull;
    clearAllSideEffects();
    addAllSideEffects(data.sideEffects);
    allowNotify();
    notifyObservers();
  }

  @override
  OperationData copy() => OperationData(
        operation: operation,
        failure: failureOrNull,
        sideEffects: sideEffects,
      );
}
