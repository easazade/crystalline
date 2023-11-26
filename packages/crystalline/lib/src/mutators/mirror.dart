import 'package:crystalline/src/data_types/data.dart';

class _Mirror<T1, D1 extends Data<T1>> {
  _Mirror(this.origin) {
    mirror = origin.copy() as D1;
    origin.addObserver(() {
      mirror.updateFrom(origin);
    });

    origin.addEventListener((event) {
      mirror.dispatchEvent(event);
      return false;
    });
  }

  final D1 origin;
  late D1 mirror;
}

extension MirrorX<T1, D1 extends Data<T1>> on D1 {
  /// returns a new instance of data object that mirrors the original data
  D1 mirror() => _Mirror<T1, D1>(this).mirror;
}
