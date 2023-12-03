import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/src/matchers.dart' as matchers;

import 'testable.dart';
import 'utils.dart';

void main() {
  late Data<String> data1;
  late Data<String> data2;
  late Data<String> data;
  Data<String> Function() getData = () => data1;

  setUp(() {
    data1 = Data();
    data2 = Data();
    data = Data();
  });

  testWidgets(
    'Should observe data and update builder when data updated',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            observe: true,
            builder: (context, data) {
              if (data.hasValue)
                return Text(data.value);
              else
                return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Container), matchers.findsOneWidget);
      expect(find.text('text'), matchers.findsNothing);

      // when data value changes
      data.value = 'text';

      await tester.pumpAndSettle();

      // expect
      expect(find.text('text'), matchers.findsOneWidget);
      expect(find.byType(Container), matchers.findsNothing);
    },
  );

  testWidgets(
    'Should observe data and update builder when data updated '
    'then when data objects changes should remove observer from old data '
    'and observe the new data instead.',
    (tester) async {
      // when data is set to data1;
      getData = () => data1;

      late Function rebuild;

      await tester.pumpWidget(
        StatefulBuilder(builder: (context, setState) {
          rebuild = () => setState(() {});

          return Testable(
            child: DataBuilder<String, Data<String>>(
              data: getData(),
              observe: true,
              builder: (context, data) {
                if (data.hasValue)
                  return Text(data.value);
                else
                  return Container();
              },
            ),
          );
        }),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Container), matchers.findsOneWidget);
      expect(find.text('text'), matchers.findsNothing);

      // when data1 value changes
      data1.value = 'text';

      await tester.pumpAndSettle();

      // expect changes from data1
      expect(find.text('text'), matchers.findsOneWidget);
      expect(find.byType(Container), matchers.findsNothing);

      // when data object is changed from data1 to data2
      getData = () => data2;
      rebuild();

      // and when data2 value changes
      data2.value = 'new value';

      await tester.pumpAndSettle();

      // expect changes on widget from data2
      expect(find.text('new value'), matchers.findsOneWidget);
      expect(find.byType(Container), matchers.findsNothing);
    },
  );

  testWidgets(
    'Should not update builder when ever data updated and observe property of DataBuilder is not set to true',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            // observe: true,
            builder: (context, data) {
              if (data.hasValue)
                return Text(data.value);
              else
                return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Container), matchers.findsOneWidget);
      expect(find.text('text'), matchers.findsNothing);

      // when data value changes
      data.value = 'text';

      await tester.pumpAndSettle();

      // expect no update from DataBuilder
      expect(find.byType(Container), matchers.findsOneWidget);
      expect(find.text('text'), matchers.findsNothing);
    },
  );

  testWidgets(
    'Builder should update widget when operation is '
    'updated on data and observe is set to true on DataBuilder',
    (tester) async {
      final Operation operation = Operation.defaultOperations
          .randomItem(exceptionValues: [Operation.none]);

      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            observe: true,
            builder: (context, data) {
              return Text(data.operation.name);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(Operation.none.name), matchers.findsOneWidget);

      // when data value changes
      data.operation = operation;

      await tester.pumpAndSettle();

      // expect
      expect(find.text(operation.name), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Builder should NOT update widget when operation is '
    'updated on data and observe is NOT set to true on DataBuilder',
    (tester) async {
      final Operation operation = Operation.defaultOperations
          .randomItem(exceptionValues: [Operation.none]);

      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            // observe: true,
            builder: (context, data) {
              return Text(data.operation.name);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(Operation.none.name), matchers.findsOneWidget);

      // when data value changes
      data.operation = operation;

      await tester.pumpAndSettle();

      // expect
      expect(find.text(operation.name), matchers.findsNothing);
      expect(find.text(Operation.none.name), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Builder should update widget when failure is '
    'updated on data and observe is set to true on DataBuilder',
    (tester) async {
      final failure = Failure('failure message');

      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            observe: true,
            builder: (context, data) {
              if (data.hasFailure)
                return Text(data.failure.message);
              else
                return Text('no failure');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('no failure'), matchers.findsOneWidget);
      expect(find.text(failure.message), matchers.findsNothing);

      // when data value changes
      data.failure = failure;

      await tester.pumpAndSettle();

      // expect
      expect(find.text(failure.message), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Builder should NOT update widget when failure is '
    'updated on data and observe is NOT set to true on DataBuilder',
    (tester) async {
      final failure = Failure('failure message');

      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            // observe: true,
            builder: (context, data) {
              if (data.hasFailure)
                return Text(data.failure.message);
              else
                return Text('no failure');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('no failure'), matchers.findsOneWidget);
      expect(find.text(failure.message), matchers.findsNothing);

      // when data value changes
      data.failure = failure;

      await tester.pumpAndSettle();

      // expect
      expect(find.text(failure.message), matchers.findsNothing);
    },
  );
}
