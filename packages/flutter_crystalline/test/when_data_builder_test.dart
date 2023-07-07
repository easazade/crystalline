import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/src/matchers.dart' as matchers;

import 'testable.dart';

void main() {
  late Data<String> data;

  setUp(() {
    data = Data();
  });
  group('WhenDataBuilder tests', () {
    testWidgets(
      'Should observe data and udpate WhenDataBuilder &'
      'Also the correct callbacks from WhenDataBuilders should be called',
      (tester) async {
        await tester.pumpWidget(
          Testable(
            child: WhenDataBuilder<String, Data<String>>(
              data: data,
              observe: true,
              onValue: (context, data) => Text(data.value),
              onNoValue: (context, data) => Text('data has no value'),
              onCreate: (context, data) => Text(data.operation.name),
              onOperate: (context, data) => Text(data.operation.name),
              onFetch: (context, data) => Text(data.operation.name),
              onDelete: (context, data) => Text(data.operation.name),
              onError: (context, data) => Text(data.error.message),
              onUpdate: (context, data) => Text(data.operation.name),
              orElse: (context, data) => Text('or else'),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.value = 'Hello';
        await tester.pumpAndSettle();
        expect(find.text('Hello'), matchers.findsOneWidget);

        data.operation = Operation.operating;
        await tester.pumpAndSettle();
        expect(find.text(Operation.operating.name), matchers.findsOneWidget);

        data.operation = Operation.create;
        await tester.pumpAndSettle();
        expect(find.text(Operation.create.name), matchers.findsOneWidget);

        data.operation = Operation.delete;
        await tester.pumpAndSettle();
        expect(find.text(Operation.delete.name), matchers.findsOneWidget);

        data.operation = Operation.update;
        await tester.pumpAndSettle();
        expect(find.text(Operation.update.name), matchers.findsOneWidget);

        data.operation = Operation.fetch;
        await tester.pumpAndSettle();
        expect(find.text(Operation.fetch.name), matchers.findsOneWidget);

        data.operation = Operation.none;
        await tester.pumpAndSettle();
        expect(find.text(data.value), matchers.findsOneWidget);
      },
    );

    testWidgets(
      'Should not udpate WhenDataBuilder when ever data updated and '
      'observe property of WhenDataBuilder is not set to true',
      (tester) async {
        await tester.pumpWidget(
          Testable(
            child: WhenDataBuilder<String, Data<String>>(
              data: data,
              // observe: true,
              onValue: (context, data) => Text(data.value),
              onNoValue: (context, data) => Text('data has no value'),
              onCreate: (context, data) => Text(data.operation.name),
              onOperate: (context, data) => Text(data.operation.name),
              onFetch: (context, data) => Text(data.operation.name),
              onDelete: (context, data) => Text(data.operation.name),
              onError: (context, data) => Text(data.error.message),
              onUpdate: (context, data) => Text(data.operation.name),
              orElse: (context, data) => Text('or else'),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.value = 'Hello';
        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.operation = Operation.operating;
        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.operation = Operation.create;
        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.operation = Operation.delete;
        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.operation = Operation.update;
        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.operation = Operation.fetch;
        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.operation = Operation.none;
        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);
      },
    );

    testWidgets(
      'WhenDataBuilder should update widget when operating when data.operation property is updated '
      'and other operation callbacks are null',
      (tester) async {
        await tester.pumpWidget(
          Testable(
            child: WhenDataBuilder<String, Data<String>>(
              data: data,
              observe: true,
              onValue: (context, data) => Text(data.value),
              onNoValue: (context, data) => Text('data has no value'),
              onOperate: (context, data) => Text('operating'),
              orElse: (context, data) => Text('or else'),
              // onCreate: (context, data) => Text(data.operation.name),
              // onFetch: (context, data) => Text(data.operation.name),
              // onDelete: (context, data) => Text(data.operation.name),
              // onError: (context, data) => Text(data.error.message),
              // onUpdate: (context, data) => Text(data.operation.name),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('data has no value'), matchers.findsOneWidget);

        data.value = 'Hello';
        await tester.pumpAndSettle();
        expect(find.text('Hello'), matchers.findsOneWidget);

        data.operation = Operation.operating;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.create;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.delete;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.update;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.fetch;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.none;
        await tester.pumpAndSettle();
        expect(find.text(data.value), matchers.findsOneWidget);
      },
    );

    testWidgets(
      'WhenDataBuilder orElse should be called when data has no value '
      'and onNoValue callback is not implemented',
      (tester) async {
        await tester.pumpWidget(
          Testable(
            child: WhenDataBuilder<String, Data<String>>(
              data: data,
              observe: true,
              onValue: (context, data) => Text(data.value),
              onOperate: (context, data) => Text('operating'),
              orElse: (context, data) => Text('or else'),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('or else'), matchers.findsOneWidget);

        data.value = 'Hello';
        await tester.pumpAndSettle();
        expect(find.text('Hello'), matchers.findsOneWidget);

        data.operation = Operation.operating;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.create;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.delete;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.update;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.fetch;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.none;
        await tester.pumpAndSettle();
        expect(find.text(data.value), matchers.findsOneWidget);

        data.value = null;
        await tester.pumpAndSettle();
        expect(find.text('or else'), matchers.findsOneWidget);
      },
    );

    testWidgets(
      'WhenDataBuilder orElse should be called when data has no value '
      'and onNoValue callback is not implemented',
      (tester) async {
        await tester.pumpWidget(
          Testable(
            child: WhenDataBuilder<String, Data<String>>(
              data: data,
              observe: true,
              onValue: (context, data) => Text(data.value),
              onOperate: (context, data) => Text('operating'),
              orElse: (context, data) => Text('or else'),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('or else'), matchers.findsOneWidget);

        data.value = 'Hello';
        await tester.pumpAndSettle();
        expect(find.text('Hello'), matchers.findsOneWidget);

        data.operation = Operation.operating;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.create;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.delete;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.update;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.fetch;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.none;
        await tester.pumpAndSettle();
        expect(find.text(data.value), matchers.findsOneWidget);

        data.value = null;
        await tester.pumpAndSettle();
        expect(find.text('or else'), matchers.findsOneWidget);
      },
    );

    testWidgets(
      'WhenDataBuilder onError should be called when data has and error'
      'and operation is set Operation.none',
      (tester) async {
        final error = Failure('message');

        await tester.pumpWidget(
          Testable(
            child: WhenDataBuilder<String, Data<String>>(
              data: data,
              observe: true,
              onValue: (context, data) => Text(data.value),
              onOperate: (context, data) => Text('operating'),
              orElse: (context, data) => Text('or else'),
              onError: (context, data) => Text(data.error.message),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('or else'), matchers.findsOneWidget);

        data.value = 'Hello';
        await tester.pumpAndSettle();
        expect(find.text('Hello'), matchers.findsOneWidget);

        data.error = error;
        await tester.pumpAndSettle();
        expect(find.text(error.message), matchers.findsOneWidget);

        data.operation = Operation.operating;
        await tester.pumpAndSettle();
        expect(find.text('operating'), matchers.findsOneWidget);

        data.operation = Operation.none;
        await tester.pumpAndSettle();
        expect(find.text(error.message), matchers.findsOneWidget);
      },
    );
  });
}
