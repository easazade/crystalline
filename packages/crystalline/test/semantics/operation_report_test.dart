import 'package:crystalline/crystalline.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late Data<String> data;
  late OperationReport operationReport1;
  late OperationReport operationReport2;

  setUp(() {
    data = Data(value: 'some-value');
    operationReport1 = OperationReport(message: 'message 1', operation: Operation.create);
    operationReport2 = OperationReport(message: 'message 2', operation: Operation.read);

    expect(operationReport1, isNot(equals(operationReport2)));
  });

  test('OperationReport - Should add operation-report object', () {
    data.semanticSideEffects.operationReports.add(operationReport1);
    expect(data.sideEffects.all.length, equals(1));
    expect(data.semanticSideEffects.operationReports.items.length, equals(1));
    expect(data.semanticSideEffects.operationReports.items.first, operationReport1);
  });

  test('OperationReport - Should be able to add multiple operation-report objects', () {
    data.semanticSideEffects.operationReports.add(operationReport1);
    expect(data.sideEffects.all.length, equals(1));
    expect(data.semanticSideEffects.operationReports.items.length, equals(1));
    expect(data.semanticSideEffects.operationReports.items[0], operationReport1);

    data.semanticSideEffects.operationReports.add(operationReport2);
    expect(data.sideEffects.all.length, equals(2));
    expect(data.semanticSideEffects.operationReports.items.length, equals(2));
    expect(data.semanticSideEffects.operationReports.items[1], operationReport2);
  });

  test('OperationReport - Should remove operation-report object', () {
    data.semanticSideEffects.operationReports.add(operationReport1);
    expect(data.semanticSideEffects.operationReports.items.first, operationReport1);

    data.semanticSideEffects.operationReports.remove(operationReport1);
    expect(data.semanticSideEffects.operationReports.items, isEmpty);
  });

  test('OperationReport - Should add operation-report object alongside other side effects', () {
    data.sideEffects.addAll(['side-effect-1', 'side-effect-2', 'side-effect-1']);
    expect(data.sideEffects.all.length, 3);

    // when adding an operation report it should work well along side effects.
    data.semanticSideEffects.operationReports.add(operationReport1);
    expect(data.semanticSideEffects.operationReports.items.first, operationReport1);
    expect(data.semanticSideEffects.operationReports.items.length, 1);
    expect(data.sideEffects.all.length, 4);

    // when removing the operation-report other side effects should not be effected.
    data.semanticSideEffects.operationReports.remove(operationReport1);
    expect(data.semanticSideEffects.operationReports.items, isEmpty);
    expect(data.sideEffects.all.length, 3);
  });
}
