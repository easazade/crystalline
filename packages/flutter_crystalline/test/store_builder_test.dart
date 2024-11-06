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
      expect(find.text(testStore.nonData), findsOneWidget);
    },
  );

  testWidgets(
    'Should rebuild the ui when publish() is called',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: StoreBuilder(
            store: testStore,
            builder: (context, store, child) {
              return Column(
                children: [
                  if (store.userName.hasValue) Text(store.userName.value),
                  if (store.age.hasValue) Text('${store.age.value}'),
                  if (store.points.hasValue) Text('${store.points.value}'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text(testStore.userName.value), findsOneWidget);

      testStore.userName.value = 'easazade';
      testStore.age.value = 30;
      testStore.points.value = 10.0;
      testStore.publish();
      await tester.pumpAndSettle();

      expect(find.text('easazade'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('10.0'), findsOneWidget);
    },
  );

  testWidgets(
    'Should NOT rebuild the ui when publish() is called',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: StoreBuilder(
            store: testStore,
            builder: (context, store, child) {
              return Column(
                children: [
                  if (store.userName.hasValue) Text(store.userName.value),
                  if (store.age.hasValue) Text('${store.age.value}'),
                  if (store.points.hasValue) Text('${store.points.value}'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text(testStore.userName.value), findsOneWidget);

      testStore.userName.value = 'easazade';
      testStore.age.value = 30;
      testStore.points.value = 10.0;
      // not calling publish
      // testStore.publish();
      await tester.pumpAndSettle();

      expect(find.text('easazade'), findsNothing);
      expect(find.text('30'), findsNothing);
      expect(find.text('10.0'), findsNothing);
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
