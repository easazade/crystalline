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

    List<_FormPageInfo> pageInfos = _extractFormPagesInfo(formAnnotationObject, formContextClassName);

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
    buffer.writeln(
      '''
      class $formClassName extends FormData {
        $formClassName({
          ${pageInfos.map((e) => 'required this.${e.customClassName.camelCase}').join(',')}
        });

        // page properties
        ${pageInfos.map((e) => 'final ${e.customClassName} ${e.customClassName.camelCase};').join('\n')}

        final $formContextClassName formContext = $formContextClassName();

        @override
        String get name => '$formName';

        @override
        late final List<FormPage> pages = [${pagesBuffer.toString()}];

        @override
        Stream<$formClassName> get stream => streamController.stream.map((e) => this);

        @override
        $formClassName copy() => throw Exception('cannot copy a generated FormData class');

      ''',
    );

    // write page submit methods to generated FormData class
    for (var pageInfo in pageInfos) {
      final inputDataValueArgs =
          pageInfo.items.map((e) => '${e.valueType.displayNameWithNullability} ${e.name}').join(',');
      buffer.writeln(
        '''
          Future<void> ${pageInfo.submitMethodName}() async {

          }

        ''',
      );
    }

    buffer.writeln(
      '''
        @override
        bool operator ==(Object other) {
          if (other is! $formClassName) return false;

          return runtimeType == other.runtimeType &&
              pages == other.pages &&
              ListEquality<InputData>().equals(items, other.items) &&
              operationOrNull == other.operationOrNull &&
              sideEffects == other.sideEffects &&
              failureOrNull == other.failureOrNull;
        }

        @override
        int get hashCode => Object.hashAll([
              pages,
              runtimeType,
              items,
              operationOrNull,
              failureOrNull,
              sideEffects.all,
            ]);
      }  
      ''',
    ); // end of custom FormData class

    // write custom args for pages and inputs
    for (final pageInfo in pageInfos) {
      buffer.writeln(pageInfo.toCustomClassCode());
    }

    // generate form context class
    buffer.writeln('class $formContextClassName {}');
  }
}

void _validate(ClassElement cls) {
  // class name must be private
  // form name should not be blank
  // page names should not be blank
  // input-data names should not be blank
}

List<_FormPageInfo> _extractFormPagesInfo(
  DartObject? formAnnotationObject,
  String formContextClassName,
) {
  final reader = ConstantReader(formAnnotationObject);
  List<_FormPageInfo> pages = [];

  final pageDartObjects = reader.read('pages').listValue;
  for (var i = 0; i < pageDartObjects.length; i++) {
    final pageInfo = pageDartObjects[i];
    final reader = ConstantReader(pageInfo);
    final pageName = reader.read('name').stringValue;
    List<_InputDataInfo> inputInfos = [];
    final submitResultType = reader.read('submitResultType').typeValue;
    final pageCustomClassName = '${pageName.pascalCase}PageArgs';

    for (var inputInfo in reader.read('items').listValue) {
      final reader = ConstantReader(inputInfo);
      final inputName = reader.read('name').stringValue;
      final inputType = reader.read('inputType').typeValue;
      final valueType = reader.read('valueType').typeValue;

      inputInfos.add(
        _InputDataInfo(
          name: inputName,
          pageCustomClassName: pageCustomClassName,
          formContextClassName: formContextClassName,
          inputType: inputType,
          valueType: valueType,
        ),
      );
    }

    pages.add(_FormPageInfo(
      name: pageName,
      items: inputInfos,
      submitResultType: submitResultType.displayNameWithNullability!,
      formContextClassName: formContextClassName,
      customClassName: pageCustomClassName,
      pageIndex: i,
    ));
  }

  return pages;
}

class _InputDataInfo {
  const _InputDataInfo({
    required this.name,
    required this.pageCustomClassName,
    required this.formContextClassName,
    required this.inputType,
    required this.valueType,
  });

  final String name;
  final String pageCustomClassName;
  final String formContextClassName;
  final DartType inputType;
  final DartType valueType;

  String toInstantiateInputDataCode() {
    final inputTypeString = inputType.displayNameWithNullability;
    final valueTypeString = valueType.displayNameWithNullability;
    return '''
    InputData<$inputTypeString, $valueTypeString>(
      name: "$name",
      validator: ($inputTypeString? input) => ${pageCustomClassName.camelCase}.${customClassName.camelCase}.validate${name.pascalCase}(formContext, input),
      onSubmit: (InputData<$inputTypeString, $valueTypeString> data) => ${pageCustomClassName.camelCase}.${customClassName.camelCase}.onSubmit${name.pascalCase}(formContext, data),
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

      final InputValidationResult Function($formContextClassName formContext, $inputTypeString? input) validate${name.pascalCase};
      
      final Future<void> Function($formContextClassName formContext, InputData<$inputTypeString, $valueTypeString> data) onSubmit${name.pascalCase};
    }

    ''';
  }

  String get customClassName => '${name.pascalCase}InputData';
}

class _FormPageInfo {
  const _FormPageInfo({
    required this.name,
    required this.formContextClassName,
    required this.items,
    required this.submitResultType,
    required this.pageIndex,
    required this.customClassName,
  });

  final String name;
  final String formContextClassName;
  final String customClassName;
  final String submitResultType;
  final List<_InputDataInfo> items;
  final int pageIndex;

  String get submitMethodName => 'submit${nameWithPageExtension.pascalCase}';
  String get onSubmitMethodName => 'onSubmitPage';

  String get nameWithPageExtension {
    var fixedName = name;
    if (fixedName.endsWith('page') || fixedName.endsWith('Page')) {
      fixedName = fixedName.substring(fixedName.length - 4);
    }
    return '${fixedName}Page';
  }

  String toCustomClassCode() {
    final buffer = StringBuffer();
    buffer.writeln('// custom class code for $customClassName');

    buffer.writeln('class $customClassName {'); // start of class
    // constructor
    final inputArgs = items.map((e) => "required this.${e.customClassName.camelCase}").join(',');
    buffer.writeln('$customClassName({ $inputArgs, required this.$onSubmitMethodName });\n');

    // input properties
    for (var inputInfo in items) {
      buffer.writeln('final ${inputInfo.customClassName} ${inputInfo.customClassName.camelCase};');
    }

    // other properties
    buffer.writeln('final submitResult = Data<$submitResultType>();');
    buffer.writeln('final pageIndex = $pageIndex;');

    // onSubmit property
    final submittedValueArgs = items.map((e) => "${e.valueType.displayNameWithNullability} ${e.name}").join(',');
    buffer.writeln(
      'final Future<void> Function($formContextClassName formContext, Data<$submitResultType> submitResult, $submittedValueArgs) $onSubmitMethodName;',
    );

    buffer.writeln('}'); // end of class

    for (var inputInfo in items) {
      buffer.writeln(inputInfo.toCustomClassCode());
    }
    return buffer.toString();
  }
}
