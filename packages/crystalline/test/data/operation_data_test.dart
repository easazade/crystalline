import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  late OperationData operationData;
  late DataTestObserver<void, OperationData> testObserver;

  late Data<String> data;

  setUp(() {
    operationData = OperationData();
    testObserver = DataTestObserver(operationData);

    data = Data(
      value: 'some value',
      operation: Operation.fetch,
      sideEffects: ['side-effect'],
      error: Failure('message'),
    );
  });

  test(
    'Should Update operationData successfully',
    () {
      expect(operationData.operation, Operation.none);
      expect(operationData.errorOrNull, isNull);
      expect(operationData.sideEffects, isEmpty);

      operationData.error = Failure('message');
      operationData.operation = Operation.create;
      operationData.addSideEffect('side-effect');

      expect(operationData.operation, Operation.create);
      expect(operationData.errorOrNull, isNotNull);
      expect(operationData.error.message, 'message');
      expect(operationData.sideEffects.length, 1);
      expect(operationData.sideEffects.first, 'side-effect');
      expect(testObserver.timesUpdated, 3);
    },
  );

  test(
    'OperationData should update from another data using updateFrom()',
    () {
      expect(operationData.operation, Operation.none);
      expect(operationData.errorOrNull, isNull);
      expect(operationData.sideEffects, isEmpty);

      operationData.updateFrom(data);

      expect(operationData.operation, data.operation);
      expect(operationData.errorOrNull, data.errorOrNull);
      expect(operationData.sideEffects, data.sideEffects);
      expect(operationData.sideEffects.length, 1);
    },
  );

  test(
    'Should create an OperationData from another data and update '
    'itself from that other data. '
    'should update operation, error and sideEffects',
    () {
      // create a new OperationData from another data
      operationData = OperationData.from(data);
      testObserver = DataTestObserver(operationData);

      // expect the created OperationData has same operation, error and sideEffect values
      // as the data it is created from
      expect(operationData.operation, data.operation);
      expect(operationData.errorOrNull, data.errorOrNull);
      expect(operationData.sideEffects, data.sideEffects);
      expect(operationData.sideEffects.length, 1);

      // when data updates, OperationData that is created from it should update as well
      data.error = Failure('message 2');
      data.operation = Operation.delete;
      data.addSideEffect('side-effect-2');

      expect(operationData.operation, Operation.delete);
      expect(operationData.errorOrNull, isNotNull);
      expect(operationData.error.message, 'message 2');
      expect(operationData.sideEffects.length, 2);
      expect(operationData.sideEffects, data.sideEffects);
      expect(operationData.sideEffects.last, 'side-effect-2');
      expect(testObserver.timesUpdated, 3);
    },
  );
}
