import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';

void writeSharedStoreClass(
  StringBuffer buffer,
  List<LibraryElement2> libraries,
) {
  final storeClasses =
      libraries.map((lib) => lib.classes.where((cls) => storeTypeChecker.hasAnnotationOfExact(cls))).flattenedToList;

  final sharedDataGetters = storeClasses
      .map((cls) => cls.getters2.where((getter) => sharedDataTypeChecker.hasAnnotationOfExact(getter)))
      .flattened;

  if (sharedDataGetters.isNotEmpty) {
    buffer.writeln('class SharedStore extends Store {');
    for (var getter in sharedDataGetters) {
      buffer.writeln('// fragments: ${getter.fragments}');
      buffer.writeln('// return type: ${getter.returnType.displayNameWithNullability} ${getter.displayName}');
      buffer.writeln('// type: ${getter.type.displayName}');
      buffer.writeln('// typeParameters: ${getter.typeParameters2}');
      buffer.writeln('// --: ${(getter.returnType as InterfaceType).typeArguments}');

      buffer.writeln('final ${getter.displayName} = ${getter.returnType.displayNameWithGenericTypes}();');
    }

    buffer.writeln(
      '''
      @override
      List<Data<Object?>> get states => [${sharedDataGetters.map((e) => e.displayName).join(',')}];

      @override
      String? get name => 'SharedStore';
      ''',
    );
    buffer.writeln('}');
  }
}
