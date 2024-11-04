import 'package:crystalline/src/data_types/data.dart';

class _Mapper<T1, T2, D1 extends Data<T1>, D2 extends Data<T2>> {
  final D1 origin;
  final D2 mappedMutation;

  _Mapper(
    this.origin,
    this.mappedMutation,
    void Function(D1 origin, D2 mutated) mapper,
  ) {
    // map current state of original data to mutated data
    mapper(origin, mappedMutation);

    // add an observer to map state of original data to mutated data on each
    origin.addObserver(() {
      mappedMutation.disallowNotify();
      mapper(origin, mappedMutation);
      mappedMutation.allowNotify();
      mappedMutation.notifyObservers();
    });
  }
}

extension MapperX<T1, D1 extends Data<T1>> on D1 {
  /// maps this data to specified [mapped] data using the [mapper] function passed.
  /// the [mapped] data will listen to updates from the original data and [mapper]
  /// callback will be called each time original data updates.
  D2 mapTo<T2, D2 extends Data<T2>>(
    D2 mapped,
    void Function(D1 origin, D2 mutated) mapper,
  ) {
    return _Mapper<T1, T2, D1, D2>(this, mapped, mapper).mappedMutation;
  }
}
