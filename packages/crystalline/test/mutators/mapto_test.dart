import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  group('mapTo', () {
    test(
      'Should map Data<int> to Data<String>',
      () {
        final intData = Data<int>();
        intData.value = 30;
        final stringData = intData.mapTo(
          mapped: Data<String>(),
          mapper: (origin, mapData) => mapData.value = origin.valueOrNull?.toString(),
        );

        final DataTestObserver<String, Data<String>> data2TestObserver = DataTestObserver(stringData);

        expect(stringData, isA<Data<String>>());
        expect(stringData.valueOrNull, isNotNull);
        expect(stringData.value, intData.value.toString());
        expect(data2TestObserver.timesUpdated, 0);
      },
    );

    test(
      'Should map Data<int> to Data<String> and object Data<String> should '
      'be updated whenever Data<int> updates',
      () {
        final intData = Data<int>();
        final stringData = intData.mapTo(
          mapped: Data<String>(),
          mapper: (origin, mapData) => mapData.value = origin.valueOrNull?.toString(),
        );

        final DataTestObserver<String, Data<String>> testObserver = DataTestObserver(stringData);

        intData.value = 20;
        expect(stringData, isA<Data<String>>());
        expect(stringData.value, isNotNull);
        expect(stringData.value, intData.value.toString());
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

        final intListData = stringListData.mapTo(
          mapped: ListData<int>([]),
          mapper: (origin, mutated) {},
        );

        expect(intListData, isA<ListData<int>>());
      },
    );
  });
}
