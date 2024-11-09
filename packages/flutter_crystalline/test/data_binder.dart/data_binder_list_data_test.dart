import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/testable.dart';

void main() async {
  late List<String> items;
  late ListData<String> listData;

  setUp(() async {
    items = ['Kian', 'Reza', 'Hasan', 'Mohsen', 'Mohammad'];
    listData = ListData<String>(items.mapToData);
  });

  testWidgets(
    'DataBinder Should rebuild when ListData changes',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: WhenDataBinder(
            data: listData,
            onValue: (context, items) {
              return Column(
                children: [
                  if (items.sideEffects.isNotEmpty)
                    Text(items.sideEffects.first.toString()),
                  ...items.map((item) => Text(item.value)).toList(),
                ],
              );
            },
            onCreate: (context, data) => CircularProgressIndicator(),
            onFailure: (context, data) => Text(data.failure.message),
          ),
        ),
      );

      for (final data in listData) {
        expect(find.text(data.value), findsOneWidget);
      }

      // check initial build
      expect(listData.operation, Operation.none);
      expect(listData.failureOrNull, isNull);
      expect(listData.sideEffects, isEmpty);

      // check side effects rendering
      listData.addSideEffect('sideEffect');
      await tester.pumpAndSettle();

      expect(find.text('sideEffect'), findsOneWidget);

      // check operation rendering
      listData.operation = Operation.create;
      await tester.pump(const Duration(milliseconds: 500));

      for (final data in listData) {
        expect(find.text(data.value), findsNothing);
      }

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // check rendering of failures
      listData.failure = Failure('Oops Error !!!');
      listData.operation = Operation.none;
      await tester.pumpAndSettle();
      expect(find.text('Oops Error !!!'), findsOneWidget);
    },
  );

  testWidgets(
    'DataBinder Should rebuild when ListData when its child items change',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBinder(
            data: listData,
            builder: (context, items) {
              return Column(
                children: [
                  if (items.sideEffects.isNotEmpty)
                    Text(items.sideEffects.first.toString()),
                  ...items.map((item) {
                    if (item.isAnyOperation)
                      return CircularProgressIndicator();
                    else
                      return Text(item.value);
                  }).toList(),
                ],
              );
            },
          ),
        ),
      );

      for (final data in listData) {
        expect(find.text(data.value), findsOneWidget);
      }

      // check initial build
      expect(listData.operation, Operation.none);
      expect(listData.failureOrNull, isNull);
      expect(listData.sideEffects, isEmpty);

      // check change value of first item in the ListData is shown
      final newValue = 'Shapoor';
      final oldValue = listData.first.value;
      expect(oldValue, isNot(equals(newValue)));

      listData.first.value = newValue;
      expect(listData.first.value, isNot(equals(oldValue)));
      await tester.pumpAndSettle();

      expect(find.text(newValue), findsOneWidget);
      for (final data in listData.items.sublist(1)) {
        expect(find.text(data.value), findsOneWidget);
      }

      // check change of operation of the first item in the ListData is shown
      listData.first.operation = Operation.fetch;
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(newValue), findsNothing);
      for (final data in listData.items.sublist(1)) {
        expect(find.text(data.value), findsOneWidget);
      }
    },
  );
}
