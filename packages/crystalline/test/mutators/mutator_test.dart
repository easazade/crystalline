import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late Data<int> data1;

  setUp(() => data1 = Data());

  test('Should map Data<int> to Data<String>', () {
    final data2 = data1.map(
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
  });

  test(
    'Should create a distinct data that only udpates when origin data has changed distinctively',
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

      final newError = DataError('message', Exception(''));
      original.error = newError;
      original.error = newError;
      original.error = newError;
      original.error = newError;

      expect(distinct.errorOrNull, newError);
      expect(distinctTestObserver.timesUpdated, 3);
    },
  );
}
