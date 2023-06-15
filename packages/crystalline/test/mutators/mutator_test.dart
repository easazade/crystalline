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
}
