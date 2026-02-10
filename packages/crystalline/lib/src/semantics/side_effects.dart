import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/semantics/events.dart';
import 'package:crystalline/src/semantics/operation.dart';

class SideEffects<T> {
  SideEffects(this.data, this._onNotify);

  final Data<T> data;
  final void Function() _onNotify;

  final List<dynamic> _sideEffects = [];

  Iterable<dynamic> get all => _sideEffects;

  void add(dynamic sideEffect) {
    _sideEffects.add(sideEffect);
    data.events.dispatch(
      AddSideEffectEvent(
        newSideEffect: sideEffect,
        sideEffects: _sideEffects,
      ),
    );
    data.events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    _onNotify();
  }

  void addAll(Iterable<dynamic> sideEffects) {
    _sideEffects.addAll(sideEffects);
    data.events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    _onNotify();
  }

  void remove(dynamic sideEffect) {
    _sideEffects.remove(sideEffect);
    data.events.dispatch(
      RemoveSideEffectEvent(
        removedSideEffect: sideEffect,
        sideEffects: _sideEffects,
      ),
    );
    data.events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    _onNotify();
  }

  bool get isEmpty => _sideEffects.isEmpty;

  bool get isNotEmpty => _sideEffects.isNotEmpty;

  void clear() {
    _sideEffects.clear();
    data.events.dispatch(SideEffectsUpdatedEvent(_sideEffects));
    _onNotify();
  }
}

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
    _data.sideEffects.add(report);
  }

  void remove(OperationReport report) {
    _data.sideEffects.remove(report);
  }

  List<OperationReport> get items => _data.sideEffects.all.whereType<OperationReport>().toList();
}

class SemanticSideEffects<T> {
  final Data<T> _data;

  SemanticSideEffects(this._data);

  late final operationReports = OperationReportsManager<T>(_data);
}

extension SemanticSideEffectsOnDataX<T> on Data<T> {
  SemanticSideEffects<T> get semanticSideEffects => SemanticSideEffects<T>(this);
}
