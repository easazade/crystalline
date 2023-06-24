import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late ContextData<String, ({String job, String car})> contextData;
  late DataTestObserver<String, ContextData<String, ({String job, String car})>>
      testObserver;

  setUp(() {
    contextData = ContextData();
    testObserver = DataTestObserver(contextData);
  });

  test('Should Update context with new context value', () {
    expect(contextData.contextOrNull, isNull);
    final expectedContext = (job: 'programmer', car: 'pars');
    contextData.context = expectedContext;
    expect(contextData.context, expectedContext);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should Update context with null value', () {
    expect(contextData.contextOrNull, isNull);
    final expectedContext = (job: 'programmer', car: 'pars');
    contextData.context = expectedContext;
    expect(contextData.context, expectedContext);
    contextData.context = null;
    expect(contextData.contextOrNull, isNull);
    expect(testObserver.timesUpdated, 2);
  });

  test('Should Update context', () {
    expect(contextData.contextOrNull, isNull);
    final expectedContext = (job: 'programmer', car: 'pars');
    contextData.context = expectedContext;
    expect(contextData.context, expectedContext);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should set value', () {
    expect(contextData.valueOrNull, isNull);
    final expectedValue = 'Some String';
    contextData.value = expectedValue;
    expect(contextData.value, expectedValue);
  });

  test(
    'Should throw Error when value of Data is null and getter value is called',
    () {
      expect(contextData.valueOrNull, isNull);
      expect(
          () => contextData.value, throwsA(isA<ValueNotAvailableException>()));
    },
  );

  test('Should set the operation', () {
    expect(contextData.operation, Operation.none);
    final expectedOperation = Operation.defaultOperations.randomItem!;
    contextData.operation = expectedOperation;
    expect(contextData.operation, expectedOperation);
  });

  test('Should set error', () {
    expect(contextData.errorOrNull, isNull);
    final expectedError = DataError('message', Exception('message'));
    contextData.error = expectedError;
    expect(contextData.error, expectedError);
  });

  test(
      'Should throw Error when error of Data is null and getter error is called',
      () {
    expect(contextData.errorOrNull, isNull);
    expect(() => contextData.error, throwsA(isA<DataErrorIsNullException>()));
  });

  test('Should modify context-data and call observers only once', () {
    contextData.modify((data) {
      data.value = 'apple';
      data.value = 'orage';
      data.operation = Operation.create;
      data.error = DataError('message', Exception('exception message'));
    });

    expect(testObserver.timesUpdated, 1);
  });

  test(
    'Should modify context-data asynchronously and call observers only once',
    () async {
      await contextData.modifyAsync((data) async {
        data.value = 'apple';
        data.value = 'orage';
        data.operation = Operation.create;
        data.error = DataError('message', Exception('exception message'));
      });

      expect(testObserver.timesUpdated, 1);
    },
  );
}
