import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/mutators/mutators.dart';

class OperationData extends Data<void> {
  OperationData({
    Operation operation = Operation.none,
    List<dynamic>? sideEffects,
    Failure? failure,
  }) : super(
          operation: operation,
          sideEffects: sideEffects,
          failure: failure,
        );

  factory OperationData.from(UnModifiableData<dynamic> data) {
    return data.mapTo(OperationData(), (origin, mutated) {
      mutated.failure = origin.failureOrNull;
      mutated.operation = origin.operation;
      mutated.clearAllSideEffects();
      mutated.addAllSideEffects(origin.sideEffects);
    });
  }

  @override
  void updateFrom(ReadableData<dynamic> data) {
    disallowNotifyObservers();
    operation = data.operation;
    failure = data.failureOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects);
    allowNotifyObservers();
    notifyObservers();
  }

  @override
  OperationData copy() => OperationData(
        operation: operation,
        failure: failureOrNull,
        sideEffects: sideEffects,
      );
}
