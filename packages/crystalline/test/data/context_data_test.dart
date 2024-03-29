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
    'Should throw Failure when value of Data is null and getter value is called',
    () {
      expect(contextData.valueOrNull, isNull);
      expect(
          () => contextData.value, throwsA(isA<ValueNotAvailableException>()));
    },
  );

  test(
    'Should throw Failure when context of Data is null and getter context is called',
    () {
      expect(contextData.contextOrNull, isNull);
      expect(() => contextData.context, throwsA(isA<ContextIsNullException>()));
    },
  );

  test(
    'hasContext getter method should return false when context is null and vise versa',
    () {
      expect(contextData.hasContext, isFalse);
      contextData.context = (job: 'programmer', car: 'pride');
      expect(contextData.hasContext, isTrue);
    },
  );

  test('Should set the operation', () {
    expect(contextData.operation, Operation.none);
    final expectedOperation = Operation.defaultOperations.randomItem!;
    contextData.operation = expectedOperation;
    expect(contextData.operation, expectedOperation);
  });

  test('Should set failure', () {
    expect(contextData.failureOrNull, isNull);
    final expectedFailure = Failure('message');
    contextData.failure = expectedFailure;
    expect(contextData.failure, expectedFailure);
  });

  test(
      'Should throw Failure when failure of Data is null and getter failure is called',
      () {
    expect(contextData.failureOrNull, isNull);
    expect(() => contextData.failure, throwsA(isA<FailureIsNullException>()));
  });

  test('Should modify context-data and call observers only once', () {
    contextData.modify((data) {
      data.value = 'apple';
      data.value = 'orange';
      data.operation = Operation.create;
      data.failure = Failure('message');
    });

    expect(testObserver.timesUpdated, 1);
  });

  test(
    'Should modify context-data asynchronously and call observers only once',
    () async {
      await contextData.modifyAsync((data) async {
        data.value = 'apple';
        data.value = 'orange';
        data.operation = Operation.create;
        data.failure = Failure('message');
      });

      expect(testObserver.timesUpdated, 1);
    },
  );

  test(
    'Should update data from another data',
    () async {
      final otherData = ContextData<String, ({String job, String car})>(
        value: 'alireza',
        context: (job: 'programmer', car: 'pars 96'),
      );
      expect(contextData, isNot(otherData));
      contextData.updateFrom(otherData);
      expect(contextData, otherData);

      expect(testObserver.timesUpdated, 1);
    },
  );

  test(
    'Should not updateData from another data because they are different types',
    () async {
      final otherData = ContextData<String, ({String job, int age})>(
        value: 'alireza',
        context: (job: 'programmer', age: 29),
      );
      expect(
        () => contextData.updateFrom(otherData),
        throwsA(isA<CannotUpdateFromTypeException>()),
      );

      expect(testObserver.timesUpdated, 0);
    },
  );
}
