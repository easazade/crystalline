import 'package:crystalline/src/data_types/data.dart';

class _Mapper<T1, T2, D1 extends UnModifiableData<T1>, D2 extends Data<T2>> {
  final D1 origin;
  final D2 mutated;

  _Mapper(
    this.origin,
    this.mutated,
    void Function(D1 origin, D2 mutated) mapper,
  ) {
    mapper(origin, mutated);
    origin.addObserver(() {
      mutated.disallowNotify();
      mapper(origin, mutated);
      mutated.allowNotify();
      mutated.notifyObservers();
    });
  }
}

extension MapperX<T1, T2, D1 extends UnModifiableData<T1>>
    on UnModifiableData<T1> {
  /// map function
  D2 mapTo<D2 extends Data<T2>>(
    D2 mapData,
    void Function(D1 origin, D2 mutated) mapper,
  ) {
    return _Mapper<T1, T2, D1, D2>(this as D1, mapData, mapper).mutated;
  }
}
