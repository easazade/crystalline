import 'package:crystalline/crystalline.dart';

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

  @override
  bool operator ==(Object other) {
    if (other is! SideEffects<T>) return false;

    return runtimeType == other.runtimeType && ListEquality<dynamic>().equals(all.toList(), other.all.toList());
  }

  @override
  int get hashCode => all.hashCode;
}
