import 'package:crystalline/src/data_types/data.dart';

class _Mapper<T1, T2, D1 extends UnModifiableData<T1>, D2 extends Data<T2>> {
  final D1 origin;
  final D2 mapData;

  _Mapper(
      this.origin, this.mapData, void Function(D1 origin, D2 mapData) mapper) {
    origin.addObserver(() => mapper(origin, mapData));
  }
}

extension MappperX<T1, T2, D1 extends UnModifiableData<T1>> on Data<T1> {
  /// map function
  D2 map<D2 extends Data<T2>>(
    D2 mapData,
    void Function(D1 origin, D2 mutated) mapper,
  ) {
    return _Mapper<T1, T2, D1, D2>(this as D1, mapData, mapper).mapData;
  }
}
