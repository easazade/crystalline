import 'package:build/build.dart';
import 'package:crystalline/annotations.dart';
import 'package:crystalline/crystalline.dart';
import 'package:crystalline_builder/src/extensions.dart';
import 'package:crystalline_builder/src/file_header.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class CrystallineBuilder implements Builder {
  final _dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  static final _dataTypeChecker = const TypeChecker.typeNamed(data);

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.crystalline.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();

    final resolver = buildStep.resolver;
    if (!(await resolver.isLibrary(buildStep.inputId))) return;
    final library = await resolver.libraryFor(buildStep.inputId);

    for (var cls in library.classes) {
      if (!_dataTypeChecker.hasAnnotationOfExact(cls)) continue;

      final dataAnnotation = _dataTypeChecker.firstAnnotationOfExact(cls);
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

    final outputId = buildStep.inputId.changeExtension('.crystalline.dart');
    final code = buffer.toString();

    if (code.isEmpty) {
      return;
    }

    var content = '''
          $generatedFileHeader        
          part of '${buildStep.inputId.path.split('/').last}';
          $code
        ''';

    content = _dartFormatter.tryFormat(content);
    await buildStep.writeAsString(outputId, content);
  }
}
