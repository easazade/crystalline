import 'package:analyzer/dart/element/element.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/functions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';
import 'package:source_gen/source_gen.dart';

void writeStoreClass(final StringBuffer buffer, final LibraryElement library) {
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

    final dataProperties = cls.fields.where(
      (e) =>
          e.type.displayName == 'Data' ||
          superclassChainOfFieldType(e.type).any((interfaceType) => interfaceType.displayName == 'Data'),
    );

    // write store class implementation

    // write constructor args for generate StoreClass
    final positionalParams = cls.unnamedConstructor!.formalParameters
        .where((p) => p.isPositional)
        .map((p) => 'super.${p.displayName}')
        .join(',')
        .trim();

    final namedParams = cls.unnamedConstructor!.formalParameters
        .where((p) => p.isNamed)
        .map((p) {
          var fragment = 'super.${p.displayName}';
          if (p.isRequired) {
            fragment = 'required $fragment';
          }
          if (p.hasDefaultValue) {
            fragment = '$fragment = ${p.defaultValueCode}';
          }

          return fragment;
        })
        .join(',')
        .trim();

    final sharedDataGetters = cls.getters.where((getter) => sharedDataTypeChecker.hasAnnotationOfExact(getter));

    final sharedPropertiesPart = sharedDataGetters.map((getter) {
      return 'final ${sharedPropertyName(getter.displayName)} =  ${getter.returnType.displayNameWithGenericTypes}();';
    }).join('\n');

    final storeClassSharedPropertiesPart = sharedDataGetters.map((getter) {
      return '@override\n'
          'final ${getter.displayName} =  ${sharedPropertyName(getter.displayName)};';
    }).join('\n');

    buffer.writeln(
      '''
        $sharedPropertiesPart

        class $storeClassName extends $className with $mixinName {
          // constructor
          $storeClassName(
            ${positionalParams.isNotEmpty ? "$positionalParams, " : ""}
            ${namedParams.isNotEmpty ? "{$namedParams}" : ""}
          );

          $storeClassSharedPropertiesPart
        }
      ''',
    );

    // write mixin
    buffer.writeln(
      '''
      mixin $mixinName on $className {
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

void validateSourceSyntaxForStoreAnnotatedClass(ClassElement cls) {
  if (!cls.isPrivate || !cls.isAbstract) {
    throw Exception('!!! ->>> Annotated store classes with @store() need to be private and abstract');
  }

  if (cls.unnamedConstructor == null) {
    throw Exception('!!! ->>> Annotated store classes with @store must have an unnamed constructor');
  }
}
