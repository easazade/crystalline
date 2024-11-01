import 'package:meta/meta.dart';

import 'data_types/collection_data.dart';
import 'data_types/data.dart';

@visibleForTesting
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
    if (n > records.length) {
      throw Exception('this data has not been update $n number of times');
    }
    fn(records[n - 1]);
  }
}

@visibleForTesting
class DataTestListener<T, D extends Data<T>> {
  DataTestListener(this.data) {
    data.addEventListener((event) {
      records.add(event);
      return false;
    });
  }

  final D data;
  List<Event> records = [];

  int get timesDispatched => records.length;

  void expectNthDispatch(int n, void Function(Event event) fn) {
    if (n <= 0) {
      throw Exception('n cannot start from 0 or be less than 0');
    }
    if (n > records.length) {
      throw Exception('this data has not had a ${n}th event dispatched');
    }
    fn(records[n - 1]);
  }
}

@visibleForTesting
typedef ListDataTestObserver<T> = DataTestObserver<List<Data<T>>, ListData<T>>;
@visibleForTesting
typedef ListDataTestEventListener<T>
    = DataTestListener<List<Data<T>>, ListData<T>>;
@visibleForTesting
typedef CollectionDataTestObserver<T>
    = DataTestObserver<List<Data<T>>, CollectionData<T>>;
