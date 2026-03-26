import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/mutators/mutators.dart';
import 'package:meta/meta.dart';

class OperationData extends Data<void> {
  OperationData({
    super.operation,
    super.sideEffects,
    super.failure,
  });

  factory OperationData.from(Data<dynamic> data) {
    return data.mapTo(
      mapped: OperationData(),
      mapper: (origin, mutated) {
        mutated.failure = origin.failureOrNull;
        mutated.operation = origin.operationOrNull;
        mutated.sideEffects.clear();
        mutated.sideEffects.addAll(origin.sideEffects.all);
      },
    );
  }

  @override
  void updateFrom(Data<dynamic> data) {
    disallowNotify();
    operation = data.operationOrNull;
    failure = data.failureOrNull;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects.all);
    allowNotify();
    notifyObserversAndStreamListeners();
  }

  @override
  OperationData copy() => OperationData(
        operation: operationOrNull,
        failure: failureOrNull,
        sideEffects: sideEffects.all,
      );

  @override
  Stream<OperationData> get stream => streamController.stream.map((e) => this);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (other is! OperationData) return false;

    return other.runtimeType == runtimeType &&
        failureOrNull == other.failureOrNull &&
        operationOrNull == other.operationOrNull &&
        ListEquality().equals(sideEffects.all.toList(), other.sideEffects.all.toList());
  }

  @override
  @mustBeOverridden
  int get hashCode => Object.hashAll([
        failureOrNull,
        sideEffects.all,
        operationOrNull,
        runtimeType,
      ]);
}
