import 'package:analyzer/dart/element/type.dart';

List<InterfaceType> superclassChainOfFieldType(DartType fieldType) {
  // Peel off nullability if needed (usually not required, but harmless)
  final t = fieldType is TypeParameterType
      ? fieldType.bound // optional: if you want the bound's supertypes
      : fieldType;

  if (t is! InterfaceType) return const [];

  final result = <InterfaceType>[];
  InterfaceType? current = t.superclass; // immediate superclass (null for Object)
  while (current != null) {
    result.add(current);
    current = current.superclass;
  }
  return result;
}
