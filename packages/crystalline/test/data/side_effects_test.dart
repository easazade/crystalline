import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late Data<String> data;
  late DataTestObserver<String, Data<String>> testObserver;

  setUp(() {
    data = Data();
    testObserver = DataTestObserver(data);
  });

  test('Should add a side effect', () {
    final sideEffect = 'effect on the side';
    data.addSideEffect(sideEffect);
    expect(data.sideEffects.length, 1);
    expect(data.sideEffects.firstOrNull, sideEffect);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should add a list of side effects', () {
    final sideEffects = ['effect1', 'effect2', 14, 4.5];
    data.addAllSideEffects(sideEffects);
    expect(data.sideEffects.length, 4);
    expect(data.sideEffects, sideEffects);
    expect(testObserver.timesUpdated, 1);
  });

  test('Should clear all side effects', () {
    final sideEffects = ['effect1', 'effect2', 14, 4.5];
    data.addAllSideEffects(sideEffects);
    expect(data.sideEffects.length, 4);
    data.clearAllSideEffects();
    expect(data.sideEffects, isEmpty);
    expect(testObserver.timesUpdated, 2);
  });
}
