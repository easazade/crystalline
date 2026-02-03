import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../test_utils/test_logger.dart';

void main() {
  late OperationData operationData;
  late DataTestObserver<void, OperationData> testObserver;

  late Data<String> data;

  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    operationData = OperationData();
    testObserver = DataTestObserver(operationData);

    data = Data(
      value: 'some value',
      operation: Operation.read,
      sideEffects: ['side-effect'],
      failure: Failure('message'),
    );
  });

  test(
    'Should Update operationData successfully',
    () {
      expect(operationData.operation, Operation.none);
      expect(operationData.failureOrNull, isNull);
      expect(operationData.sideEffects, isEmpty);

      operationData.failure = Failure('message');
      operationData.operation = Operation.create;
      operationData.sideEffects.add('side-effect');

      expect(operationData.operation, Operation.create);
      expect(operationData.failureOrNull, isNotNull);
      expect(operationData.failure.message, 'message');
      expect(operationData.sideEffects.all.length, 1);
      expect(operationData.sideEffects.all.first, 'side-effect');
      expect(testObserver.timesUpdated, 3);
    },
  );

  test(
    'OperationData should update from another data using updateFrom()',
    () {
      expect(operationData.operation, Operation.none);
      expect(operationData.failureOrNull, isNull);
      expect(operationData.sideEffects.all, isEmpty);

      operationData.updateFrom(data);

      expect(operationData.operation, data.operation);
      expect(operationData.failureOrNull, data.failureOrNull);
      expect(operationData.sideEffects.all, data.sideEffects.all);
      expect(operationData.sideEffects.all.length, 1);
    },
  );

  test(
    'Should create an OperationData from another data and update '
    'itself from that other data. '
    'should update operation, failure and sideEffects',
    () {
      // create a new OperationData from another data
      operationData = OperationData.from(data);
      testObserver = DataTestObserver(operationData);

      // expect the created OperationData has same operation, failure and sideEffect values
      // as the data it is created from
      expect(operationData.operation, data.operation);
      expect(operationData.failureOrNull, data.failureOrNull);
      expect(operationData.sideEffects.all, data.sideEffects.all);
      expect(operationData.sideEffects.all.length, 1);

      // when data updates, OperationData that is created from it should update as well
      data.failure = Failure('message 2');
      data.operation = Operation.delete;
      data.sideEffects.add('side-effect-2');

      expect(operationData.operation, Operation.delete);
      expect(operationData.failureOrNull, isNotNull);
      expect(operationData.failure.message, 'message 2');
      expect(operationData.sideEffects.all.length, 2);
      expect(operationData.sideEffects.all, data.sideEffects.all);
      expect(operationData.sideEffects.all.last, 'side-effect-2');
      expect(testObserver.timesUpdated, 3);
    },
  );
}
