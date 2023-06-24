import 'package:crystalline/src/data_types/data.dart';

class Distinct<T1, D1 extends Data<T1>> {
  Distinct(this.origin) {
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

extension DistinctX<T1, D1 extends Data<T1>> on Data<T1> {
  /// distinct function
  D1 distinct() => Distinct<T1, D1>(this as D1).distinct;
}
