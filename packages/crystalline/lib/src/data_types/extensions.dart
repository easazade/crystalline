import 'package:crystalline/crystalline.dart';

extension CrystallineDataX<T> on Data<T> {
  /// returns an [OperationData] that observers this data
  OperationData toOperationData() => OperationData.from(this);

  /// returns [Data] as [UnModifiableData]
  UnModifiableData<T> unModifiable() => this;
}

extension CrystallineIterableX<T> on Iterable<T> {
  List<Data<T>> get mapToData => map((e) => Data(value: e)).toList();
}
