import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../test_utils/test_logger.dart';

class CollectionDataTestImpl<T> extends CollectionData<T> {
  CollectionDataTestImpl(this.items);
  final List<Data<T>> items;

  @override
  CollectionData<T> copy() => super.copy();
}

void main() {
  late CollectionDataTestImpl<String> collectionData;
  late List<Data<String>> items1;
  late CollectionDataTestObserver<String> testObserver;

  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    collectionData = CollectionDataTestImpl([]);
    items1 = ['apple', 'orange', 'ananas', 'banana'].map((e) => Data(value: e)).toList();
    testObserver = DataTestObserver(collectionData);
  });

  test('Should copy() correctly', () {
    collectionData.addAll(items1);

    final copied = collectionData.copy();

    expect(copied, collectionData);
    expect(testObserver.timesUpdated, 1);
  });
}
