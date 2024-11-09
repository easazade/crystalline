import 'package:flutter/widgets.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/testable.dart';

void main() {
  late Data<String> data;

  setUp(() {
    data = Data();
  });

  testWidgets(
    'Should rebuild data on change',
    (tester) async {
      data.value = 'Ali';

      await tester.pumpWidget(
        Testable(
          child: WhenDataBinder(
            data: data,
            onValue: (context, data) => Text('onValue ${data.value}'),
          ),
        ),
      );

      expect(find.text('onValue Ali'), findsOneWidget);

      data.value = 'Alireza';
      await tester.pumpAndSettle();

      expect(find.text('onValue Alireza'), findsOneWidget);
    },
  );

  testWidgets(
    'Should call correct callbacks when data properties update',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: WhenDataBinder(
            data: data,
            onValue: (context, data) => Text(data.value),
            onNoValue: (context, data) => Text('onNoValue'),
            onCreate: (context, data) => Text(data.operation.name),
            onFetch: (context, data) => Text(data.operation.name),
            onAnyOperation: (context, data) => Text(data.operation.name),
            onDelete: (context, data) => Text(data.operation.name),
            onUpdate: (context, data) => Text(data.operation.name),
            onFailure: (context, data) => Text(data.failure.message),
          ),
        ),
      );

      expect(find.text('onNoValue'), findsOneWidget);

      data.value = 'Ali';
      await tester.pumpAndSettle();
      expect(find.text('Ali'), findsOneWidget);
      expect(find.text('onNoValue'), findsNothing);

      data.operation = Operation.create;
      await tester.pumpAndSettle();
      expect(find.text('create'), findsOneWidget);
      expect(find.text('Ali'), findsNothing);

      data.operation = Operation.fetch;
      await tester.pumpAndSettle();
      expect(find.text('fetch'), findsOneWidget);
      expect(find.text('create'), findsNothing);

      data.operation = Operation.delete;
      await tester.pumpAndSettle();
      expect(find.text('delete'), findsOneWidget);
      expect(find.text('fetch'), findsNothing);

      data.operation = Operation.update;
      await tester.pumpAndSettle();
      expect(find.text('update'), findsOneWidget);
      expect(find.text('delete'), findsNothing);

      data.operation = Operation('like-photo');
      await tester.pumpAndSettle();
      expect(find.text('like-photo'), findsOneWidget);
      expect(find.text('delete'), findsNothing);

      data.operation = Operation.none;
      data.failure = Failure('oops error !!!');
      await tester.pumpAndSettle();
      expect(find.text('oops error !!!'), findsOneWidget);
      expect(find.text('like-photo'), findsNothing);
    },
  );

  testWidgets(
    'Custom operations should be passed to onOperate callback '
    'if onCustomOperation callback is not implemented',
    (tester) async {
      data.value = 'Ali';

      await tester.pumpWidget(
        Testable(
          child: WhenDataBinder(
            data: data,
            onValue: (context, data) => Text(data.value),
            onAnyOperation: (context, data) => Text(data.operation.name),
          ),
        ),
      );

      expect(find.text('Ali'), findsOneWidget);

      data.operation = Operation('update-profile-image');
      await tester.pumpAndSettle();

      expect(find.text('update-profile-image'), findsOneWidget);
    },
  );

  testWidgets(
    'orElse callback should be called when the relevant callback for current state of '
    'Data is not implemented.',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: WhenDataBinder(
            data: data,
            onValue: (context, data) => Text(data.value),
            orElse: (context, data) => Text('or else'),
          ),
        ),
      );

      expect(find.text('or else'), findsOneWidget);
    },
  );

  testWidgets(
    'fallback widget should be shown when the relevant callback for current state of '
    'Data is not implemented. and orElse is not implemented either.',
    (tester) async {
      await tester.pumpWidget(
        Testable(
          child: WhenDataBinder(
            data: data,
            onValue: (context, data) => Text(data.value),
            fallback: Center(),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    },
  );

  testWidgets(
    'Should observe data and update builder when data updated '
    'then when data objects changes should remove observer from old data '
    'and observe the new data instead.',
    (tester) async {
      final data1 = Data<String>();
      final data2 = Data<String>();
      // when data is set to data1;
      Data<String> Function() getData = () => data1;

      late Function rebuild;

      await tester.pumpWidget(
        StatefulBuilder(builder: (context, setState) {
          rebuild = () => setState(() {});

          return Testable(
            child: WhenDataBinder(
              data: getData(),
              onValue: (context, data) => Text(data.value),
              onNoValue: (context, data) => Container(),
            ),
          );
        }),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('text'), findsNothing);

      // when data1 value changes
      data1.value = 'text';

      await tester.pumpAndSettle();

      // expect changes from data1
      expect(find.text('text'), findsOneWidget);
      expect(find.byType(Container), findsNothing);

      // when data object is changed from data1 to data2
      getData = () => data2;
      rebuild();

      // and when data2 value changes
      data2.value = 'new value';

      await tester.pumpAndSettle();

      // expect changes on widget from data2
      expect(find.text('new value'), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    },
  );
}
