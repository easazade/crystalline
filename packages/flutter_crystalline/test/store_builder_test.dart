import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/testable.dart';

void main() {
  late TestStore testStore;

  setUp(() {
    testStore = TestStore();
  });

  testWidgets(
    'Should build the ui with initial value from TestStore',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: StoreBuilder(
            store: testStore,
            builder: (context, store, child) {
              return Column(
                children: [
                  Text(store.userName.value),
                  Text(store.nonData),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text(testStore.userName.value), findsOneWidget);
    },
  );
}

class TestStore extends Store {
  final userName = Data<String>(value: 'alireza');
  final age = Data<int>();
  final points = Data<double>();

  // this field should not cause a rebuild, since it is not part of the states
  final nonData = 'something';

  @override
  List<Data<Object?>> get states => [userName, age, points];
}
