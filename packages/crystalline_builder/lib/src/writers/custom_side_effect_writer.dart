import 'package:analyzer/dart/element/element.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

void writeCustomSideEffectExtensions(StringBuffer buffer, LibraryElement library) {
  for (var alias in library.typeAliases) {
    if (!customSideEffectTypeChecker.hasAnnotationOfExact(alias)) continue;

    _validate(alias);

    final annotation = customSideEffectTypeChecker.firstAnnotationOfExact(alias);
    final reader = ConstantReader(annotation);
    final sideEffectName = reader.read('name').stringValue;
    final sideEffectType = reader.read('type').typeValue.displayName;
    final sideEffectTypeWithNullability = '$sideEffectType?';

    final dataType = alias.aliasedType.displayNameWithGenericTypes;
    final key = '${sideEffectName}_${sideEffectType}_key'.camelCase;
    final extensionClassName = '${dataType.replaceAll('>', '_').replaceAll('<', '_').replaceAll(',', '_').camelCase}X';

    buffer.writeln(
      '''
      const $key = '$key';

      extension $extensionClassName on $dataType {
        set $sideEffectName($sideEffectTypeWithNullability value) {
          sideEffects.add(MapEntry($key, value));
        }

        $sideEffectTypeWithNullability get $sideEffectName {
          final match = this.sideEffects.all.firstWhereOrNull((e) => e is MapEntry && e.key == $key);
          if (match != null) {
            return (match as MapEntry).value;
          } else {
            return null;
          }
        }
      }
      ''',
    );
  }
}

void _validate(TypeAliasElement alias) {
  final annotation = customSideEffectTypeChecker.firstAnnotationOfExact(alias);
  final reader = ConstantReader(annotation);
  final sideEffectName = reader.read('name').stringValue;
  final sideEffectType = reader.read('type');

  if (sideEffectName.trim().isEmpty) {
    throw Exception(
      'Alias "${alias.displayName}" annotated with @CustomSideEffect must '
      'have a valid name argument in its annotation',
    );
  }

  if (sideEffectType.isNull) {
    throw Exception(
      'Alias "${alias.displayName}" annotated with @CustomSideEffect must '
      'have a valid type argument in its annotation',
    );
  }
}
