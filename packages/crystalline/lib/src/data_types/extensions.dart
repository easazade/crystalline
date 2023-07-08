import 'package:crystalline/crystalline.dart';

extension DataX<T> on Data<T> {
  OperationData toOperationData() => OperationData.from(this);
}
