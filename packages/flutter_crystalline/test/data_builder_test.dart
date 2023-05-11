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

  testWidgets('Should observe data and udpate builder when data updated',
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
  });

  testWidgets(
      'Should not udpate builder when data updated when observe property is not set to true',
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
  });
}
