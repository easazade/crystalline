import 'package:crystalline/crystalline.dart';
import 'package:crystalline/src/data_types/operation_data.dart';

extension DataX<T> on Data<T> {
  OperationData toOperationData() => OperationData.from(this);
}
