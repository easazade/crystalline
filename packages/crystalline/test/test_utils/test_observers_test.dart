import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

void main() {
  late Data<String> data;
  late DataTestObserver<String, Data<String>> testObserver;

  setUp(() {
    data = Data();
    testObserver = DataTestObserver(data);
  });

  test('Should record the correct number of times a data emits', () {
    expect(testObserver.timesUpdated, 0);
    data.operation = Operation.create;
    expect(testObserver.timesUpdated, 1);
  });

  test(
    'Should record the state of data correctly on each emission',
    () {
      data.value = 'something';
      final first = data.copy();
      data.value = 'something else';
      final second = data.copy();
      testObserver.expectNthUpdate(1, (data) => data == first);
      testObserver.expectNthUpdate(2, (data) => data == second);
    },
  );

  test(
    'Should throw exception when checking a data update that is not emitted yet',
    () {
      data.value = 'something';

      expect(testObserver.timesUpdated, isNot(2));
      expect(
        () => testObserver.expectNthUpdate(2, (data) {}),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'Should throw exception when using less than 1 as the number for checking the '
    'update emitted',
    () {
      data.value = 'something';

      expect(testObserver.timesUpdated, equals(1));
      expect(
        () => testObserver.expectNthUpdate(0, (data) {}),
        throwsA(isA<Exception>()),
      );
    },
  );
}
