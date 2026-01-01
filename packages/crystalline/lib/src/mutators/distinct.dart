import 'package:crystalline/src/data_types/data.dart';

class _Distinct<T1, D1 extends Data<T1>> {
  _Distinct(this.origin) {
    distinct = origin.copy() as D1;
    origin.addObserver(() {
      if (origin != distinct) {
        distinct.updateFrom(origin);
      }
    });
  }

  final D1 origin;
  late D1 distinct;
}

extension DistinctX<T1, D1 extends Data<T1>> on D1 {
  /// distinct is an instance mirror of the original data but is only notified of updates
  /// from the original data when some field of the original data has changed.
  ///
  /// eg: if original data is a Data\<String\> with value of "apple"
  /// and the value of original data is again updated with the same value "apple". the
  /// the distinct data object will not notify its listeners, since there was no
  /// actual change in the original data object
  D1 distinct() => _Distinct<T1, D1>(this).distinct;
}
