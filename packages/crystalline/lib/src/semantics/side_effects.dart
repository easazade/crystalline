import 'package:crystalline/crystalline.dart';

class OperationReport {
  final String type;
  final String message;
  final Operation operation;

  OperationReport({
    required this.message,
    required this.operation,
  }) : type = 'operation-report';
}

class OperationReportsManager<T> {
  final Data<T> _data;

  OperationReportsManager(this._data);

  void add(OperationReport report) {
    _data.addSideEffect(report);
  }

  void remove(OperationReport report) {
    _data.removeSideEffect(report);
  }

  List<OperationReport> get items =>
      _data.sideEffects.whereType<OperationReport>().toList();
}

class SemanticSideEffects<T> {
  final Data<T> _data;

  SemanticSideEffects(this._data);

  late final operationReports = OperationReportsManager<T>(_data);
}

extension SemanticSideEffectsOnDataX<T> on Data<T> {
  SemanticSideEffects<T> get semanticSideEffects =>
      SemanticSideEffects<T>(this);
}
