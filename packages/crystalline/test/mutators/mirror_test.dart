import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  late Data<int> data1;

  setUp(() => data1 = Data());

  test(
    'Should create a mirror data that updates every time origin data has been updated',
    () {
      final original = data1;
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
