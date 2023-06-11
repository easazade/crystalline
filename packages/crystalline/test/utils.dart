import 'dart:math';

import 'package:crystalline/src/collection_data.dart';
import 'package:crystalline/src/data.dart';

final _random = Random();

extension ListExt<T> on Iterable<T> {
  T? get randomItem {
    if (length == 0) return null;
    return elementAt(_random.nextInt(length));
  }
}

class DataTestObserver<T, D extends Data<T>> {
  DataTestObserver(this.data) {
    data.addObserver(() => records.add(data.copy() as D));
  }

  final D data;
  List<D> records = [];

  int get timesUpdated => records.length;

  void expectNthUpdate(int n, void Function(D data) fn) {
    if (n <= 0) {
      throw Exception('n cannot start from 0 or be less than 0');
    }
    fn(records[n - 1]);
  }
}

typedef ListDataTestObserver<T> = DataTestObserver<List<Data<T>>, ListData<T>>;
