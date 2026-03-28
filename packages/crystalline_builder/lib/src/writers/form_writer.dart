import 'package:analyzer/dart/element/element.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';
import 'package:source_gen/source_gen.dart';

void writeFormClass(final StringBuffer buffer, final LibraryElement library) {
  for (var cls in library.classes) {
    if (!formClassTypeChecker.hasAnnotationOfExact(cls)) continue;
    _validate(cls);

    final formAnnotation = formClassTypeChecker.firstAnnotationOfExact(cls);
    final reader = ConstantReader(formAnnotation);
  }
}

void _validate(ClassElement cls) {}
