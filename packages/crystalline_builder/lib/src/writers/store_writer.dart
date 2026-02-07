import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
// ignore: unused_import
import 'package:crystalline/crystalline.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';
import 'package:source_gen/source_gen.dart';

void writeStoreClass(final StringBuffer buffer, final LibraryElement2 library) {
  for (var cls in library.classes) {
    if (!storeTypeChecker.hasAnnotationOfExact(cls)) continue;
    validateSourceSyntaxForStoreAnnotatedClass(cls);

    final storeAnnotation = storeTypeChecker.firstAnnotationOfExact(cls);
    // nothing to read from annotation for now
    // ignore: unused_local_variable
    final reader = ConstantReader(storeAnnotation);

    final className = cls.displayName;
    final mixinName = '${className}Mixin';
    final storeClassName = className.replaceAll('_', '');

    final dataProperties = cls.fields2.where((e) => e.type.displayName == 'Data');

    for (var property in dataProperties) {
      print(property.displayName);
      print(property.type.displayNameWithNullability);
      print((property.type as ParameterizedType).typeArguments);
    }

    // write store class implementation
    buffer.writeln(
      '''
        class $storeClassName extends $className with $mixinName {}
      ''',
    );
    // write mixin
    buffer.writeln(
      '''
      mixin $mixinName on $className{
        // override
        List<Data<Object?>> get states => [${dataProperties.map((e) => e.displayName).join(',')}];

        // override
        String? get name => '$className';
      }
      ''',
    );

    // validate source syntax
    // add callback methods to the mixin
  }
}

void validateSourceSyntaxForStoreAnnotatedClass(ClassElement2 cls) {
  if (!cls.isPrivate || !cls.isAbstract) {
    throw Exception('!!! -> Annotated store classes need to be private and abstract');
  }
}
