import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/src/matchers.dart' as matchers;

import 'utils/testable.dart';

void main() {
  late Data<String> data;

  setUp(() {
    data = Data();
  });

  testWidgets(
    'when observing'
    'Should observe a data instance and then when data instance changed '
    'with another one should stop observing the old data and '
    'observe/update from new the new data instance',
    (tester) async {
      Data<String> Function() getData = () => data;

      late Function rebuild;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = () => setState(() {});

            return Testable(
              child: DataBinder(
                data: getData(),
                builder: (context, data) {
                  return WhenDataBuilder<String, Data<String>>(
                    data: getData(),
                    onValue: (context, data) => Text(data.value),
                  );
                },
              ),
            );
          },
        ),
      );

      data.value = 'value from data';

      rebuild();
      await tester.pumpAndSettle();
      expect(find.text('value from data'), matchers.findsOneWidget);

      final newData = Data<String>();
      getData = () => newData;

      newData.value = 'value from new data';

      rebuild();
      await tester.pumpAndSettle();
      expect(find.text('value from new data'), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Should observe data and update WhenDataBuilder &'
    'Also the correct callbacks from WhenDataBuilders should be called',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBinder(
            data: data,
            builder: (context, data) {
              return WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
                onNoValue: (context, data) => Text('data has no value'),
                onCreate: (context, data) => Text(data.operation.name),
                onRead: (context, data) => Text(data.operation.name),
                onDelete: (context, data) => Text(data.operation.name),
                onFailure: (context, data) => Text(data.failure.message),
                onUpdate: (context, data) => Text(data.operation.name),
                onAnyOperation: (context, data) => Text(data.operation.name),
                orElse: (context, data) => Text('or else'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);

      data.value = 'Hello';
      await tester.pumpAndSettle();
      expect(find.text('Hello'), matchers.findsOneWidget);

      data.operation = Operation.create;
      await tester.pumpAndSettle();
      expect(find.text(Operation.create.name), matchers.findsOneWidget);

      data.operation = Operation.delete;
      await tester.pumpAndSettle();
      expect(find.text(Operation.delete.name), matchers.findsOneWidget);

      data.operation = Operation.update;
      await tester.pumpAndSettle();
      expect(find.text(Operation.update.name), matchers.findsOneWidget);

      data.operation = Operation.read;
      await tester.pumpAndSettle();
      expect(find.text(Operation.read.name), matchers.findsOneWidget);

      data.operation = Operation('delete-photo');
      await tester.pumpAndSettle();
      expect(find.text('delete-photo'), matchers.findsOneWidget);

      data.operation = Operation.none;
      await tester.pumpAndSettle();
      expect(find.text(data.value), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Should update WhenDataBuilder when parent widget rebuilds'
    'Also the correct callbacks from WhenDataBuilders should be called',
    (tester) async {
      late Function rebuildParent;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuildParent = () => setState(() {});

            return Testable(
              child: WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
                onNoValue: (context, data) => Text('data has no value'),
                onCreate: (context, data) => Text(data.operation.name),
                onRead: (context, data) => Text(data.operation.name),
                onDelete: (context, data) => Text(data.operation.name),
                onFailure: (context, data) => Text(data.failure.message),
                onUpdate: (context, data) => Text(data.operation.name),
                onAnyOperation: (context, data) => Text(data.operation.name),
                orElse: (context, data) => Text('or else'),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);

      data.value = 'Hello';
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text('Hello'), matchers.findsOneWidget);

      data.operation = Operation.create;
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text(Operation.create.name), matchers.findsOneWidget);

      data.operation = Operation.delete;
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text(Operation.delete.name), matchers.findsOneWidget);

      data.operation = Operation.update;
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text(Operation.update.name), matchers.findsOneWidget);

      data.operation = Operation.read;
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text(Operation.read.name), matchers.findsOneWidget);

      data.operation = Operation('update-user-profile');
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text('update-user-profile'), matchers.findsOneWidget);

      data.operation = Operation.none;
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text(data.value), matchers.findsOneWidget);

      data.failure = Failure('oops!');
      rebuildParent();
      await tester.pumpAndSettle();
      expect(find.text(data.failure.message), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'WhenDataBuilder Should not have the responsibility to observe data and '
    'rebuild when ever data updated',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: WhenDataBuilder<String, Data<String>>(
            data: data,
            onValue: (context, data) => Text(data.value),
            onNoValue: (context, data) => Text('data has no value'),
            onCreate: (context, data) => Text(data.operation.name),
            onRead: (context, data) => Text(data.operation.name),
            onDelete: (context, data) => Text(data.operation.name),
            onFailure: (context, data) => Text(data.failure.message),
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

      data.operation = Operation.create;
      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);

      data.operation = Operation.delete;
      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);

      data.operation = Operation.update;
      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);

      data.operation = Operation.read;
      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);

      data.operation = Operation.none;
      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'WhenDataBuilder should update widget when data.operation property is updated '
    'and other operation callbacks are null',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBinder(
            data: data,
            builder: (context, data) {
              return WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
                onNoValue: (context, data) => Text('data has no value'),
                onAnyOperation: (context, data) => Text('operating'),
                orElse: (context, data) => Text('or else'),
                // onCreate: (context, data) => Text(data.operation.name),
                // onRead: (context, data) => Text(data.operation.name),
                // onDelete: (context, data) => Text(data.operation.name),
                // onFailure: (context, data) => Text(data.failure.message),
                // onUpdate: (context, data) => Text(data.operation.name),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('data has no value'), matchers.findsOneWidget);

      data.value = 'Hello';
      await tester.pumpAndSettle();
      expect(find.text('Hello'), matchers.findsOneWidget);

      data.operation = Operation.create;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.delete;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.update;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.read;
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
          child: DataBinder(
            data: data,
            builder: (context, data) {
              return WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
                onAnyOperation: (context, data) => Text('operating'),
                orElse: (context, data) => Text('or else'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('or else'), matchers.findsOneWidget);

      data.value = 'Hello';
      await tester.pumpAndSettle();
      expect(find.text('Hello'), matchers.findsOneWidget);

      data.operation = Operation.create;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.delete;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.update;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.read;
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
          child: DataBinder(
            data: data,
            builder: (context, data) {
              return WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
                onAnyOperation: (context, data) => Text('operating'),
                orElse: (context, data) => Text('or else'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('or else'), matchers.findsOneWidget);

      data.value = 'Hello';
      await tester.pumpAndSettle();
      expect(find.text('Hello'), matchers.findsOneWidget);

      data.operation = Operation.create;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.delete;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.update;
      await tester.pumpAndSettle();
      expect(find.text('operating'), matchers.findsOneWidget);

      data.operation = Operation.read;
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
    'WhenDataBuilder onFailure should be called when data has and failure'
    'and operation is set Operation.none',
    (tester) async {
      final failure = Failure('message');

      await tester.pumpWidget(
        Testable(
          child: DataBinder(
            data: data,
            builder: (context, data) {
              return WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
                onAnyOperation: (context, data) => Text('operating'),
                orElse: (context, data) => Text('or else'),
                onFailure: (context, data) => Text(data.failure.message),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('or else'), matchers.findsOneWidget);

      data.value = 'Hello';
      await tester.pumpAndSettle();
      expect(find.text('Hello'), matchers.findsOneWidget);

      data.failure = failure;
      await tester.pumpAndSettle();
      expect(find.text(failure.message), matchers.findsOneWidget);

      data.operation = Operation.none;
      await tester.pumpAndSettle();
      expect(find.text(failure.message), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Should user fallback widget when data has no value and '
    'onNoValue() and orElse() callbacks are not provided',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBinder(
            data: data,
            builder: (context, data) {
              return WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'Should orElse when data has no value and onNoValue() callback not provided',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: DataBinder(
              data: data,
              builder: (context, data) {
                return WhenDataBuilder<String, Data<String>>(
                  data: data,
                  onValue: (context, data) => Text(data.value),
                  orElse: (context, data) => Text('or else'),
                );
              }),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('or else'), matchers.findsOneWidget);
    },
  );

  testWidgets(
    'orElse should be called when data has no value and onNoValue()'
    ' callback not provided',
    (tester) async {
      late Function rebuild;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = () => setState(() {});

            return Testable(
              child: WhenDataBuilder<String, Data<String>>(
                data: data,
                onValue: (context, data) => Text(data.value),
                orElse: (context, data) => Text('or else'),
              ),
            );
          },
        ),
      );

      rebuild();
      await tester.pumpAndSettle();
      expect(find.text('or else'), matchers.findsOneWidget);
    },
  );
}
