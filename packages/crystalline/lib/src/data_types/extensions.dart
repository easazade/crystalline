import 'package:crystalline/crystalline.dart';

extension DataX<T> on Data<T> {
  /// returns an [OperationData] that observers this data
  OperationData toOperationData() => OperationData.from(this);

  /// returns [Data] as [UnModifiableData]
  UnModifiableData<T> unModifiable() => this;
}
