import 'package:build/build.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/file_header.dart';
import 'package:crystalline_builder/src/writers/data_writer.dart';
import 'package:crystalline_builder/src/writers/store_writer.dart';
import 'package:dart_style/dart_style.dart';

class CrystallineBuilder implements Builder {
  final _dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

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

    writeDataClass(buffer, library);
    
    writeStoreClass(buffer, library);

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
