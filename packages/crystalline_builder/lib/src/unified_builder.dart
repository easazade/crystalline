import 'package:build/build.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/file_header.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

/// A builder that scans all Dart files in the lib directory and generates
/// a single unified file containing all generated data and store classes.
///
/// This builder runs once per package by processing a single trigger file.
class UnifiedCrystallineBuilder implements Builder {
  final _dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  @override
  Map<String, List<String>> get buildExtensions => const {
        '^lib/main.dart': ['lib/crystalline_generated.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only process the trigger file - this ensures the builder runs once per package
    final triggerFile = 'lib/main.dart';
    if (buildStep.inputId.path != triggerFile) {
      return;
    }

    // Use the expected output based on our build extension declaration
    // We declared ^lib/main.dart -> lib/crystalline_generated.dart
    final outputId = AssetId(
      buildStep.inputId.package,
      'lib/crystalline_generated.dart',
    );

    // Find all Dart files in the lib directory
    final dartFiles = await buildStep
        .findAssets(
          Glob('lib/**/*.dart'),
        )
        .toList();

    // Filter out generated files and the trigger/output files
    final sourceFiles = dartFiles.where((id) {
      final path = id.path;
      return path != 'lib/main.dart' && // Exclude trigger file
          path != 'lib/crystalline_generated.dart' && // Exclude output file
          !path.endsWith('.crystalline_generated.dart') &&
          !path.endsWith('.crystalline.dart') &&
          !path.endsWith('.g.dart') &&
          !path.endsWith('.freezed.dart');
    }).toList();

    if (sourceFiles.isEmpty) {
      return;
    }

    final buffer = StringBuffer();
    final processedLibraries = <String>{};

    // Process each library file
    for (final inputId in sourceFiles) {
      final resolver = buildStep.resolver;
      if (!(await resolver.isLibrary(inputId))) continue;

      try {
        final library = await resolver.libraryFor(inputId);
        final libraryUri = inputId.uri.toString();

        // Skip if we've already processed this library
        if (processedLibraries.contains(libraryUri)) {
          continue;
        }
        processedLibraries.add(libraryUri);
        buffer.writeln('// $libraryUri');
      } catch (e) {
        // Skip files that can't be resolved (e.g., test files, etc.)
        continue;
      }
    }

    final code = buffer.toString();

    if (code.isEmpty) {
      return;
    }

    // Add necessary imports
    var content = '''
    $generatedFileHeader
    import 'package:crystalline/crystalline.dart';

    $code
    ''';

    content = _dartFormatter.tryFormat(content);
    await buildStep.writeAsString(outputId, content);
  }
}
