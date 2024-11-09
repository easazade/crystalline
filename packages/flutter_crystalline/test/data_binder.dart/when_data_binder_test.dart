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
            onOperate: (context, data) => Text(data.operation.name),
            onDelete: (context, data) => Text(data.operation.name),
            onUpdate: (context, data) => Text(data.operation.name),
            onCustomOperation: (context, data) => Text(data.operation.name),
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

      data.operation = Operation.operating;
      await tester.pumpAndSettle();
      expect(find.text('operating'), findsOneWidget);
      expect(find.text('fetch'), findsNothing);

      data.operation = Operation.delete;
      await tester.pumpAndSettle();
      expect(find.text('delete'), findsOneWidget);
      expect(find.text('operating'), findsNothing);

      data.operation = Operation('like-photo');
      await tester.pumpAndSettle();
      expect(find.text('like-photo'), findsOneWidget);
      expect(find.text('update'), findsNothing);

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
            onOperate: (context, data) => Text(data.operation.name),
          ),
        ),
      );

      expect(find.text('Ali'), findsOneWidget);

      data.operation = Operation('update-profile-image');
      await tester.pumpAndSettle();

      expect(find.text('update-profile-image'), findsOneWidget);
    },
  );
}
