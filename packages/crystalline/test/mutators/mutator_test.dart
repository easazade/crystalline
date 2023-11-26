import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  group('mutation functionality', () {
    late Data<int> data1;

    setUp(() => data1 = Data());

    test(
      'Should map Data<int> to Data<String> and Data<String>',
      () {
        data1.value = 30;
        final data2 = data1.mapTo<String, Data<String>>(
          Data<String>(),
          (origin, mapData) => mapData.value = origin.valueOrNull?.toString(),
        );

        final DataTestObserver<String, Data<String>> data2TestObserver =
            DataTestObserver(data2);

        expect(data2, isA<Data<String>>());
        expect(data2.valueOrNull, isNotNull);
        expect(data2.value, data1.value.toString());
        expect(data2TestObserver.timesUpdated, 0);
      },
    );

    test(
      'Should map Data<int> to Data<String> and Data<String> should '
      'be updated whenever Data<int> updates',
      () {
        final data2 = data1.mapTo<String, Data<String>>(
          Data<String>(),
          (origin, mapData) => mapData.value = origin.valueOrNull?.toString(),
        );

        final DataTestObserver<String, Data<String>> testObserver =
            DataTestObserver(data2);

        data1.value = 20;
        expect(data2, isA<Data<String>>());
        expect(data2.value, isNotNull);
        expect(data2.value, data1.value.toString());
        expect(testObserver.timesUpdated, 1);
      },
    );

    test(
      'Should create a distinct data that only updates when origin data has changed distinctively',
      () {
        final original = data1;
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
      'Should create a mirror data that updates every time origin data has changed distinctively',
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
  });

  group(
    'mutated type checking -',
    () {
      test(
        'A ListData<String> should correctly be mapped to new instance of ListData<int> using mapTo mutator function',
        () {
          final stringListData = ListData<String>([
            Data(value: '1'),
            Data(value: '2'),
          ]);

          final intListData =
              stringListData.mapTo<List<Data<int>>, ListData<int>>(
            ListData<int>([]),
            (origin, mutated) {},
          );

          expect(intListData, isA<ListData<int>>());
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
    },
  );
}
