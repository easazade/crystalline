import 'package:build/build.dart';
import 'package:crystalline_builder/src/extensions.dart';
import 'package:crystalline_builder/src/file_header.dart';
import 'package:dart_style/dart_style.dart';

class CrystallineBuilder implements Builder {
  final _dartFormatter =
      DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  // static final _crystallineScopeTypeChecker = const TypeChecker.typeNamed(CrystallineScope);

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.crystalline.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();

    final outputId = buildStep.inputId.changeExtension('.crystalline.dart');
    var content = '''
          $generatedFileHeader        
          part of '${buildStep.inputId.path.split('/').last}';
          ${buffer.toString()}
        ''';

    content = _dartFormatter.tryFormat(content);
    await buildStep.writeAsString(outputId, content);
  }
}
