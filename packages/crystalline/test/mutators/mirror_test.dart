import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Should create a mirror data that updates every time origin data has been updated',
    () {
      final original = Data<int>();
      final mirror = original.mirror();

      final DataTestObserver<int, Data<int>> mirrorTestObserver =
          DataTestObserver(mirror);

      original.value = 20;
      original.value = 20;
      original.value = 20;
      original.value = 20;

      expect(mirror.valueOrNull, 20);
      expect(mirrorTestObserver.timesUpdated, 4);

      original.operation = Operation.create;
      original.operation = Operation.create;
      original.operation = Operation.create;
      original.operation = Operation.create;

      expect(mirror.operation, Operation.create);
      expect(mirrorTestObserver.timesUpdated, 8);

      final newFailure = Failure('message');
      original.failure = newFailure;
      original.failure = newFailure;
      original.failure = newFailure;
      original.failure = newFailure;

      expect(mirror.failureOrNull, newFailure);
      expect(mirrorTestObserver.timesUpdated, 12);
    },
  );

  test(
    'Should create a mirror data that dispatches events every time original data dispatches events',
    () {
      final original = Data<int>();
      final mirror = original.mirror();

      final mirrorTestListener = DataTestListener<int, Data<int>>(mirror);

      original.value = 20;
      expect(mirror.valueOrNull, 20);
      mirrorTestListener.expectNthDispatch(
        1,
        (event) => expect(event, ValueEvent(20)),
      );

      original.value = 30;
      expect(mirror.valueOrNull, 30);
      mirrorTestListener.expectNthDispatch(
        2,
        (event) => expect(event, ValueEvent(30)),
      );

      final failure = Failure('message');
      original.failure = failure;
      expect(mirror.failureOrNull, failure);
      mirrorTestListener.expectNthDispatch(
        3,
        (event) => expect(event, FailureEvent(failure)),
      );

      final operation = Operation.create;
      original.operation = operation;
      expect(mirror.operation, operation);
      mirrorTestListener.expectNthDispatch(
        4,
        (event) => expect(event, OperationEvent(operation)),
      );
    },
  );

  test(
    'A ListData should correctly be mapped to new instance of ListData using mirror mutator function',
    () {
      final stringListData = ListData<String>([
        Data(value: '1'),
        Data(value: '2'),
      ]);

      final newListData = stringListData.mirror();
      expect(newListData, isA<ListData<String>>());
      expect(stringListData, newListData);
    },
  );
}
