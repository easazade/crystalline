import 'package:analyzer/dart/element/element2.dart';
// ignore: unused_import
import 'package:crystalline/crystalline.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/functions.dart';
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

    // for (var property in cls.fields2) {
    //   print(property.displayName);
    //   print(superclassChainOfFieldType(property.type).map((e) => e.displayName));
    //   print(property.type.displayNameWithNullability);
    //   print((property.type as ParameterizedType).typeArguments);
    // }

    final dataProperties = cls.fields2.where(
      (e) =>
          e.type.displayName == 'Data' ||
          superclassChainOfFieldType(e.type).any((interfaceType) => interfaceType.displayName == 'Data'),
    );

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
        @override
        List<Data<Object?>> get states => [${dataProperties.map((e) => e.displayName).join(',')}];

        @override
        String? get name => '$storeClassName';
      }
      ''',
    );

    // validate source syntax
    // add callback methods to the mixin
  }
}

void validateSourceSyntaxForStoreAnnotatedClass(ClassElement2 cls) {
  if (!cls.isPrivate || !cls.isAbstract) {
    throw Exception('!!! ->>> Annotated store classes with @store() need to be private and abstract');
  }
}
