import 'data_types/collection_data.dart';
import 'data_types/data.dart';

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

typedef ListDataTestObserver<T> = DataTestObserver<List<Data<T>>, ListData<T>>;
typedef CollectionDataTestObserver<T>
    = DataTestObserver<List<Data<T>>, CollectionData<T>>;
