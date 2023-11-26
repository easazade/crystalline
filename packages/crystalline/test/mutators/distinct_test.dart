import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Should create a distinct data that only updates when origin data has changed distinctively',
    () {
      final original = Data<int>();
      final distinct = original.distinct();

      final DataTestObserver<int, Data<int>> distinctTestObserver =
          DataTestObserver(distinct);

      original.value = 20;
      original.value = 20;
      original.value = 20;
      original.value = 20;

      expect(distinct.valueOrNull, 20);
      expect(distinctTestObserver.timesUpdated, 1);

      original.operation = Operation.create;
      original.operation = Operation.create;
      original.operation = Operation.create;
      original.operation = Operation.create;

      expect(distinct.operation, Operation.create);
      expect(distinctTestObserver.timesUpdated, 2);

      final newFailure = Failure('message');
      original.failure = newFailure;
      original.failure = newFailure;
      original.failure = newFailure;
      original.failure = newFailure;

      expect(distinct.failureOrNull, newFailure);
      expect(distinctTestObserver.timesUpdated, 3);
    },
  );

  test(
    'A ListData should correctly be mapped to new instance of ListData using distinct mutator function',
    () {
      final stringListData = ListData<String>([
        Data(value: '1'),
        Data(value: '2'),
      ]);

      final newListData = stringListData.distinct();
      expect(newListData, isA<ListData<String>>());
      expect(stringListData, newListData);
    },
  );
}
