import 'package:crystalline/src/data_types/data.dart';

class Mapper<T1, T2, D1 extends ReadableObservableData<T1>,
    D2 extends Data<T2>> {
  final D1 origin;
  final D2 mapData;

  Mapper(
      this.origin, this.mapData, void Function(D1 origin, D2 mapData) mapper) {
    origin.addObserver(() => mapper(origin, mapData));
  }
}

extension DataX<T1, T2, D1 extends ReadableObservableData<T1>> on Data<T1> {
  /// map function
  D2 map<D2 extends Data<T2>>(
    D2 mapData,
    void Function(D1 origin, D2 mutated) mapper,
  ) {
    return Mapper<T1, T2, D1, D2>(this as D1, mapData, mapper).mapData;
  }
}
