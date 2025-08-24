import 'package:build/build.dart';
import 'package:crystalline/annotations.dart';
import 'package:crystalline_builder/src/extensions.dart';
import 'package:crystalline_builder/src/file_header.dart';
import 'package:dart_style/dart_style.dart';
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
      final customDataClassName = cls.displayName;
      final customOperations = reader.read('customOperations').listValue.map((e) => ConstantReader(e).stringValue);

      buffer.writeln('// $customDataClassName: $customOperations');

      buffer.writeln('class ${customDataClassName}Operation extends Operation {');
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
