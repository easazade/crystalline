import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
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
    'A ListData<String> should correctly be mapped to new instance of ListData<int> using mapTo mutator function',
    () {
      final stringListData = ListData<String>([
        Data(value: '1'),
        Data(value: '2'),
      ]);

      final intListData = stringListData.mapTo<List<Data<int>>, ListData<int>>(
        ListData<int>([]),
        (origin, mutated) {},
      );

      expect(intListData, isA<ListData<int>>());
    },
  );
}
