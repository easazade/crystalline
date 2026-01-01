import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/operation_data.dart';

extension CrystallineDataX<T> on Data<T> {
  /// returns an [OperationData] that observers this data
  OperationData toOperationData() => OperationData.from(this);
}

extension CrystallineIterableX<T> on Iterable<T> {
  List<Data<T>> mapToDataList() => map((e) => Data(value: e)).toList();
}
