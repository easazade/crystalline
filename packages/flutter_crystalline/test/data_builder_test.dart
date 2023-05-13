import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/src/matchers.dart' as matchers;

import 'testable.dart';
import 'utils.dart';

void main() {
  late Data<String> data;

  setUp(() {
    data = Data();
  });

  testWidgets(
    'Should observe data and udpate builder when data updated',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            observe: true,
            builder: (context, data) {
              if (data.isAvailable)
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
    'Should not udpate builder when ever data updated and observe property of DataBuilder is not set to true',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            // observe: true,
            builder: (context, data) {
              if (data.isAvailable)
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
      final Operation operation =
          Operation.values.randomItem(exceptionValues: [Operation.none]);

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
      final Operation operation =
          Operation.values.randomItem(exceptionValues: [Operation.none]);

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
    'Builder should update widget when error is '
    'updated on data and observe is set to true on DataBuilder',
    (tester) async {
      final error =
          DataError('error message', Exception('some other error message'));

      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            observe: true,
            builder: (context, data) {
              if (data.hasError)
                return Text(data.error.message);
              else
                return Text('no error');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('no error'), matchers.findsOneWidget);
      expect(find.text(error.message), matchers.findsNothing);

      // when data value changes
      data.error = error;

      await tester.pumpAndSettle();

      // expect
      expect(find.text(error.message), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Builder should NOT update widget when error is '
    'updated on data and observe is NOT set to true on DataBuilder',
    (tester) async {
      final error =
          DataError('error message', Exception('some other error message'));

      await tester.pumpWidget(
        Testable(
          child: DataBuilder<String, Data<String>>(
            data: data,
            // observe: true,
            builder: (context, data) {
              if (data.hasError)
                return Text(data.error.message);
              else
                return Text('no error');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('no error'), matchers.findsOneWidget);
      expect(find.text(error.message), matchers.findsNothing);

      // when data value changes
      data.error = error;

      await tester.pumpAndSettle();

      // expect
      expect(find.text(error.message), matchers.findsNothing);
    },
  );
}
