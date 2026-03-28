import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

void writeFormClass(final StringBuffer buffer, final LibraryElement library) {
  for (var cls in library.classes) {
    if (!formClassTypeChecker.hasAnnotationOfExact(cls)) continue;
    _validate(cls);

    final formAnnotationObject = formClassTypeChecker.firstAnnotationOfExact(cls);
    final reader = ConstantReader(formAnnotationObject);
    final formName = reader.read('name').stringValue;
    final formClassName = '${formName.pascalCase.replaceAll('Form', '').replaceAll('from', '')}Form';
    final formContextClassName = '${formClassName}Context';

    List<_FormPageInfo> pageInfos = _extractFormPagesInfo(formAnnotationObject);

    buffer.writeln('// Generating custom form class "$formClassName"');

    final pagesBuffer = StringBuffer();

    // write FormPage list code

    for (final pageInfo in pageInfos) {
      pagesBuffer.writeln(
        '''
        FormPage(
          name: '${pageInfo.name}',
          items: [ ${pageInfo.items.map((inputData) => inputData.toInstantiateInputDataCode()).join(',')} ],
        ),
      ''',
      );
    }

    // write FormData code
    //
    buffer.writeln('''
      class $formClassName extends FormData {
        $formClassName(
      ''');

    buffer.writeln(
      '''
        ) :super(
          name: '$formName',
          pages: [${pagesBuffer.toString()}],
        );
      }
      ''',
    );

    // write custom args for pages and inputs
    for (final pageInfo in pageInfos) {
      buffer.writeln(pageInfo.toCustomClassCode());
    }

    // generate form context class
    buffer.writeln('class $formContextClassName {}');
  }
}

void _validate(ClassElement cls) {
  // form name should not be blank
  // page names should not be blank
  // input-data names should not be blank
}

List<_FormPageInfo> _extractFormPagesInfo(DartObject? formAnnotationObject) {
  final reader = ConstantReader(formAnnotationObject);
  List<_FormPageInfo> pages = [];

  for (var pageInfo in reader.read('pages').listValue) {
    final reader = ConstantReader(pageInfo);
    final pageName = reader.read('name').stringValue;
    List<_InputDataInfo> inputInfos = [];

    for (var inputInfo in reader.read('items').listValue) {
      final reader = ConstantReader(inputInfo);
      final inputName = reader.read('name').stringValue;
      final inputType = reader.read('inputType').typeValue;
      final valueType = reader.read('valueType').typeValue;

      inputInfos.add(
        _InputDataInfo(
          name: inputName,
          inputType: inputType,
          valueType: valueType,
        ),
      );
    }

    pages.add(_FormPageInfo(name: pageName, items: inputInfos));
  }

  return pages;
}

class _InputDataInfo {
  const _InputDataInfo({required this.name, required this.inputType, required this.valueType});

  final String name;
  final DartType inputType;
  final DartType valueType;

  String toInstantiateInputDataCode() {
    final inputTypeString = inputType.displayNameWithNullability;
    final valueTypeString = valueType.displayNameWithNullability;
    return '''
    InputData<$inputTypeString, $valueTypeString>(
      name: "$name",
      validator: ($inputTypeString? input) {},
      onSubmit: (InputData<$inputTypeString, $valueTypeString> data) async {},
    )
    ''';
  }

  String toCustomClassCode() {
    final inputTypeString = inputType.displayNameWithNullability;
    final valueTypeString = valueType.displayNameWithNullability;

    return '''
    class $customClassName {
      $customClassName({
        required this.validate${name.pascalCase},
        required this.onSubmit${name.pascalCase},
      });

      final InputValidationResult Function($inputTypeString? input) validate${name.pascalCase};
      final Future<void> Function(InputData<$inputTypeString, $valueTypeString> data) onSubmit${name.pascalCase};
    }

    ''';
  }

  String get customClassName => '${name.pascalCase}InputData';
}

class _FormPageInfo {
  const _FormPageInfo({required this.name, required this.items});

  final String name;
  final List<_InputDataInfo> items;

  String toCustomClassCode() {
    final buffer = StringBuffer();
    buffer.writeln('// custom class code for $customClassName');

    buffer.writeln('class $customClassName {'); // start of class
    // constructor
    final inputArgs = items.map((e) => "required this.${e.customClassName.camelCase}").join(',');
    buffer.writeln('$customClassName({ $inputArgs, required this.onSubmit });\n');

    // input properties
    for (var inputInfo in items) {
      buffer.writeln('final ${inputInfo.customClassName} ${inputInfo.customClassName.camelCase};');
    }
    // onSubmit property
    buffer.writeln('final Future<void> Function(${items.map(
          (e) => "${e.valueType.displayNameWithNullability} ${e.name}",
        ).join(',')}) onSubmit;');

    buffer.writeln('}'); // end of class

    for (var inputInfo in items) {
      buffer.writeln(inputInfo.toCustomClassCode());
    }
    return buffer.toString();
  }

  String get customClassName => '${name.pascalCase}Page';
}
