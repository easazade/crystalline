import 'package:crystalline/src/data_types/data.dart';

class _Mirror<T1, D1 extends Data<T1>> {
  _Mirror(this.origin) {
    mirror = origin.copy() as D1;
    origin.addObserver(() {
      mirror.updateFrom(origin);
    });
  }

  final D1 origin;
  late D1 mirror;
}

extension MirrorX<T1, D1 extends Data<T1>> on Data<T1> {
  /// returns a new instace of data obejct that mirrors the original data
  D1 mirror() => _Mirror<T1, D1>(this as D1).mirror;
}
