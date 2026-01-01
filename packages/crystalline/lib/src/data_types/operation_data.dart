import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/mutators/mutators.dart';

class OperationData extends Data<void> {
  OperationData({
    super.operation,
    super.sideEffects,
    super.failure,
  });

  factory OperationData.from(Data<dynamic> data) {
    return data.mapTo<dynamic, OperationData>(
      OperationData(),
      (origin, mutated) {
        mutated.failure = origin.failureOrNull;
        mutated.operation = origin.operation;
        mutated.removeAllSideEffects();
        mutated.addAllSideEffects(origin.sideEffects);
      },
    );
  }

  @override
  void updateFrom(Data<dynamic> data) {
    disallowNotify();
    operation = data.operation;
    failure = data.failureOrNull;
    removeAllSideEffects();
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

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);
}
