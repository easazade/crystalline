import 'package:analyzer/dart/element/element2.dart';
import 'package:crystalline/crystalline.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

void writeDataClass(
  StringBuffer buffer,
  LibraryElement2 library,
){
      for (var cls in library.classes) {
      if (!dataTypeChecker.hasAnnotationOfExact(cls)) continue;

      final dataAnnotation = dataTypeChecker.firstAnnotationOfExact(cls);
      final reader = ConstantReader(dataAnnotation);
      final customDataClassName = cls.displayName.replaceAll('_', '');
      final customOperations = reader.read('customOperations').listValue.map((e) => ConstantReader(e).stringValue);
      final customOperationClassName = '${customDataClassName}Operation';
      final valueType = reader.read('valueType').typeValue.displayNameWithNullability;

      // Generating custom operation class
      buffer.writeln('// Custom Data $customDataClassName with custom operations: $customOperations');

      buffer.writeln('class $customOperationClassName extends Operation {');
      buffer.writeln('const $customOperationClassName(String name) : super(name);\n');
      for (final operation in Operation.defaultOperations) {
        buffer.writeln(
            "static const $customOperationClassName ${operation.name} = $customOperationClassName('${operation.name}');");
      }
      buffer.writeln('// custom operations');
      for (final operation in customOperations) {
        buffer.writeln("static const Operation ${operation.camelCase} = Operation('$operation');");
      }
      buffer.writeln('}');

      // Generating mixin for custom data class

      buffer.writeln('''
        class $customDataClassName extends Data<$valueType>{
          $customDataClassName({
            $valueType? value,
            Failure? failure,
            $customOperationClassName operation = $customOperationClassName.none,
            Iterable<dynamic>? sideEffects,
            String? name,
          }): super(
            value: value,
            failure: failure,
            operation: operation,
            sideEffects: sideEffects,
            name: name,
          );
        }
      ''');
    }
}