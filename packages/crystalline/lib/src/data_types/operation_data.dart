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
        mutated.sideEffects.clear();
        mutated.sideEffects.addAll(origin.sideEffects.all);
      },
    );
  }

  @override
  void updateFrom(Data<dynamic> data) {
    disallowNotify();
    operation = data.operation;
    failure = data.failureOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects.all);
    allowNotify();
    observers.notify();
  }

  @override
  OperationData copy() => OperationData(
        operation: operation,
        failure: failureOrNull,
        sideEffects: sideEffects.all,
      );

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);
}
