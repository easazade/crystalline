import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/semantics/observers.dart';

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
    origin.observers.add(
      Observer(() {
        mappedMutation.disallowNotify();
        mapper(origin, mappedMutation);
        mappedMutation.allowNotify();
        mappedMutation.observers.notify();
      }),
    );
  }
}

extension MapperX<T1, D1 extends Data<T1>> on D1 {
  /// Maps this data to [mapped] using the [mapper] callback.
  ///
  /// The [mapped] data will listen to updates from this data, and [mapper] will
  /// be called whenever this data changes. Type arguments are inferred from
  /// [mapped], so you typically don't need to pass them explicitly.
  ///
  /// Example:
  /// ```dart
  /// final stringData = intData.mapTo(
  ///   Data<String>(),
  ///   (origin, mapped) => mapped.value = origin.valueOrNull?.toString(),
  /// );
  /// ```
  D2 mapTo<T2, D2 extends Data<T2>>({
    required D2 mapped,
    required void Function(D1 origin, D2 mutated) mapper,
  }) {
    return _Mapper<T1, T2, D1, D2>(this, mapped, mapper).mappedMutation;
  }
}
