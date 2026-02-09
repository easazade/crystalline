import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:crystalline_builder/src/utils/functions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';

void writeSharedStateClass(
  StringBuffer buffer,
  List<LibraryElement> libraries,
) {
  for (var lib in libraries) {
    buffer.writeln("import '${lib.uri}';");
    final unit = lib.firstFragment;

    final imports = unit.libraryImports;

    for (final imp in imports) {
      buffer.writeln(" import '${imp.importedLibrary?.uri.toString()}';");
    }
    buffer.writeln();
  }

  final storeClasses =
      libraries.map((lib) => lib.classes.where((cls) => storeTypeChecker.hasAnnotationOfExact(cls))).flattenedToList;

  final sharedDataGetters = storeClasses
      .map((cls) => cls.getters.where((getter) => sharedDataTypeChecker.hasAnnotationOfExact(getter)))
      .flattened;

  if (sharedDataGetters.isNotEmpty) {
    buffer.writeln(
      '''
      class SharedState {
        static SharedState? _instance;
        static SharedState get instance {
          if (_instance == null) {
            _instance = SharedState();
          }

          return _instance!;
        }
      ''',
    );

    // add shared data properties
    for (var getter in sharedDataGetters) {
      buffer.writeln('final ${getter.displayName} = ${sharedPropertyName(getter.displayName)};');
    }
    buffer.writeln('}'); // end of shared state class
  }
}
