import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  late Data<String> data;

  setUp(() {
    data = Data();
  });

  test('Should set value', () {
    expect(data.valueOrNull, isNull);
    final expectedValue = 'Some String';
    data.value = expectedValue;
    expect(data.value, expectedValue);
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
    final expectedOperation = Operation.values.randomItem!;
    data.operation = expectedOperation;
    expect(data.operation, expectedOperation);
  });

  test('Should set error', () {
    expect(data.errorOrNull, isNull);
    final expectedError = DataError('message', Exception('message'));
    data.error = expectedError;
    expect(data.error, expectedError);
  });

  test(
      'Should throw Error when error of Data is null and getter error is called',
      () {
    expect(data.errorOrNull, isNull);
    expect(() => data.error, throwsA(isA<DataErrorIsNullException>()));
  });
}
