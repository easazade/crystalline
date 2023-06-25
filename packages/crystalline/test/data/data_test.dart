import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late Data<String> data;
  late DataTestObserver<String, Data<String>> testObserver;

  setUp(() {
    data = Data();
    testObserver = DataTestObserver(data);
  });

  test('Should set value', () {
    expect(data.valueOrNull, isNull);
    final expectedValue = 'Some String';
    data.value = expectedValue;
    expect(data.value, expectedValue);
    expect(testObserver.timesUpdated, 1);
  });

  test(
    'Should throw Error when value of Data is null and getter value is called',
    () {
      expect(data.valueOrNull, isNull);
      expect(() => data.value, throwsA(isA<ValueNotAvailableException>()));
    },
  );

  test('Should set the operation', () {
    expect(data.operation, Operation.none);
    final expectedOperation = Operation.defaultOperations.randomItem!;
    data.operation = expectedOperation;
    expect(data.operation, expectedOperation);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should set error', () {
    expect(data.errorOrNull, isNull);
    final expectedError = DataError('message');
    data.error = expectedError;
    expect(data.error, expectedError);
    expect(testObserver.timesUpdated, 1);
  });

  test(
      'Should throw Error when error of Data is null and getter error is called',
      () {
    expect(data.errorOrNull, isNull);
    expect(() => data.error, throwsA(isA<DataErrorIsNullException>()));
  });

  test('Should modify data and call observers only once', () {
    data.modify((data) {
      data.value = 'apple';
      data.value = 'orage';
      data.operation = Operation.create;
      data.error = DataError('message');
    });

    expect(testObserver.timesUpdated, 1);
  });

  test(
    'Should modify data asynchronously and call observers only once',
    () async {
      await data.modifyAsync((data) async {
        data.value = 'apple';
        data.value = 'orage';
        data.operation = Operation.create;
        data.error = DataError('message');
      });

      expect(testObserver.timesUpdated, 1);
    },
  );

  test(
    'Should udpateData from another data',
    () async {
      final otherData = Data(value: 'subway');
      expect(data == otherData, isFalse);
      data.updateFrom(otherData);
      expect(data == otherData, isTrue);

      expect(testObserver.timesUpdated, 1);
    },
  );
}
