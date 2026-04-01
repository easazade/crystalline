import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
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
    final formClassName = '${formName.pascalCase.removeSuffix('form')}Form';
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
          ${pageInfos.map((e) => 'required ${e.argsClassName} ${e.argsClassName.camelCase}').join(',')},
          Operation? operation,
          Failure? failure,
          List<dynamic>? sideEffects,
        }): ${pageInfos.map((e) => '${e.argsClassPrivateVarName} = ${e.argsClassName.camelCase}').join(',')},
            super(operation: operation, failure: failure, sideEffects: sideEffects);

        // page properties
        ${pageInfos.map((e) => 'final ${e.argsClassName} ${e.argsClassPrivateVarName};').join('\n')}

        late final $formContextClassName formContext = $formContextClassName(pages);

      ''',
    );

    // writing short-hand getters for pages and input-data items
    if (pageInfos.length == 1) {
      final pageInfo = pageInfos[0];
      for (var item in pageInfo.items) {
        buffer.writeln(
          '${item.dataType} get ${item.name} => '
          'formContext.${pageInfo.contextClassInstanceVarName}.${item.name};',
        );
      }
      buffer.writeln(
        'Data<${pageInfo.submitResultType}> get submitResult => '
        'formContext.${pageInfo.contextClassInstanceVarName}.submitResult;',
      );
      buffer.writeln('\n');
    } else {
      for (var pageInfo in pageInfos) {
        buffer.writeln(
          '${pageInfo.contextClassName} get ${pageInfo.contextClassInstanceVarName} => '
          'formContext.${pageInfo.contextClassInstanceVarName};',
        );
      }
    }

    buffer.writeln(
      '''
        @override
        late final List<FormPage> pages = [${pagesBuffer.toString()}];

        @override
        String get name => '$formName';

        @override
        Stream<$formClassName> get stream => streamController.stream.map((e) => this);

        @override
        $formClassName copy() => $formClassName(
          ${pageInfos.map(_pageCopyArgFragment).join('')}
          operation: operationOrNull,
          failure: failureOrNull,
          sideEffects: sideEffects.all.toList(),
        );

        // Satisfies [Data]'s @mustBeOverridden; behavior is [FormData.updateFrom].
        @override
        // ignore: unnecessary_overrides
        void updateFrom(Data<List<InputData<dynamic, dynamic>>> data) {
          super.updateFrom(data);
        }

      ''',
    );

    final submitMethods = <SubmitMethodInfo>[];

    // write page submit methods to generated FormData class
    for (var pageInfo in pageInfos) {
      var submitMethodName = pageInfo.submitMethodName;
      if (pageInfos.length == 1) {
        // if form only has one page there is no need for generating a separate submit method for that name
        //
        submitMethodName = '_$submitMethodName';
      }

      submitMethods.add(SubmitMethodInfo(
        method: submitMethodName,
        submitResultGetter: 'formContext.${pageInfo.contextClassInstanceVarName}.submitResult',
        pageName: pageInfo.nameWithPageExtension,
        alwaysRetry: pageInfos.length == 1,
      ));

      buffer.writeln(
        '''
          Future<void> $submitMethodName() async {
            final page = pages[${pageInfo.argsClassPrivateVarName}.pageIndex];
            for (var inputItem in page.items) {
              if (inputItem.isOptional) {
                continue;
              }
              if (inputItem.hasNoValue) {
                await inputItem.submit();
                // if still no value return;
                if (inputItem.hasNoValue) {
                  return;
                }
              }
            }

            // when all inputData items of the page have a value then submit page
            await ${pageInfo.argsClassPrivateVarName}.onSubmitPage(
                formContext,
                formContext.${pageInfo.contextClassInstanceVarName}.submitResult,
                ${pageInfo.submitValuesCallbackArgsClassName}(${pageInfo.items.mapIndexed((index, _) => "page.items[$index].value").join(',\n')}),
              );

            if (formContext.${pageInfo.contextClassInstanceVarName}.submitResult.hasFailure && formContext.${pageInfo.contextClassInstanceVarName}.submitResult.failure.type == null) {
              formContext.${pageInfo.contextClassInstanceVarName}.submitResult.failure =
                  formContext.${pageInfo.contextClassInstanceVarName}.submitResult.failure.copyWith(type: FailureType.error);

            } else if (formContext.${pageInfo.contextClassInstanceVarName}.submitResult.hasNoValue && !formContext.${pageInfo.contextClassInstanceVarName}.submitResult.hasFailure) {
              final message = '! No value or failure was set on submitResult data inside ${pageInfo.onSubmitMethodName} argument callback for ${pageInfo.name} page when it was called.';
              formContext.${pageInfo.contextClassInstanceVarName}.submitResult.failure = Failure(message, type: FailureType.error);
              CrystallineGlobalConfig.logger.log(CrystallineGlobalConfig.logger.redText(message));
            }  
          }

        ''',
      );
    }

    // override submit method from FormData for the generated form class
    var reSubmitArgs = submitMethods.map((e) {
      if (!e.alwaysRetry) {
        return 'bool reSubmit${e.pageName.pascalCase} = false,';
      } else {
        return '';
      }
    }).join();

    if (reSubmitArgs.trim().isNotEmpty) {
      reSubmitArgs = '{ $reSubmitArgs }';
    }
    buffer.writeln(
      '''
      @override
      Future submit($reSubmitArgs) async {
      ''',
    );

    if (submitMethods.length == 1) {
      final submitMethod = submitMethods[0];
      buffer.writeln('await ${submitMethod.method}();');
    } else {
      for (var submitMethod in submitMethods) {
        buffer.writeln(
          '''
        if(${submitMethod.submitResultGetter}.hasNoValue || reSubmit${submitMethod.pageName.pascalCase}) {
          await ${submitMethod.method}();
          if(${submitMethod.submitResultGetter}.hasFailure){
            return;
          }
        }
        ''',
        );
      }
    }

    // end of submit override
    buffer.writeln('}');

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
      buffer.writeln(pageInfo.toFormArgumentsClassCode());
    }

    // write custom args for pages
    for (final pageInfo in pageInfos) {
      buffer.writeln(pageInfo.toContextClassCode());
    }

    // write submit values argument class
    for (final pageInfo in pageInfos) {
      buffer.writeln(pageInfo.toOnSubmitCallbackArgumentsClass());
    }

    // generate form context class
    buffer.writeln(
      '''
      class $formContextClassName {
        $formContextClassName(this._pages);
        final List<FormPage> _pages;

        ${pageInfos.map((e) => 'late final ${e.contextClassInstanceVarName} = ${e.contextClassName}(_pages, ${e.pageIndex});').join('\n')}
      }
      ''',
    );
  }
}

String _pageCopyArgFragment(_FormPageInfo pageInfo) {
  final itemBlocks = pageInfo.items.mapIndexed((i, item) => '''
      ${item.argsClassName.camelCase}: ${item.argsClassName}(
        validate${item.name.pascalCase}: ${pageInfo.argsClassPrivateVarName}.${item.argsClassName.camelCase}.validate${item.name.pascalCase},
        onSubmit${item.name.pascalCase}: ${pageInfo.argsClassPrivateVarName}.${item.argsClassName.camelCase}.onSubmit${item.name.pascalCase},
        isOptional: pages[${pageInfo.pageIndex}].items[$i].isOptional,
        hint: pages[${pageInfo.pageIndex}].items[$i].hint,
        initialValue: (pages[${pageInfo.pageIndex}].items[$i] as ${item.dataType}).valueOrNull,
        initialInput: (pages[${pageInfo.pageIndex}].items[$i] as ${item.dataType}).inputOrNull,
        operation: pages[${pageInfo.pageIndex}].items[$i].operationOrNull,
        failure: pages[${pageInfo.pageIndex}].items[$i].failureOrNull,
        sideEffects: pages[${pageInfo.pageIndex}].items[$i].sideEffects.all.toList(),
      )
''').join(',');
  return '''
          ${pageInfo.argsClassName.camelCase}: ${pageInfo.argsClassName}(
$itemBlocks,
            onSubmitPage: ${pageInfo.argsClassPrivateVarName}.onSubmitPage,
          ),
''';
}

void _validate(ClassElement cls) {
  // class name must be private
  if (!cls.isPrivate) {
    throw Exception('classes Annotated with @FormClass() need to be private.');
  }

  // form name should not be blank
  final annotation = formClassTypeChecker.firstAnnotationOfExact(cls);
  final reader = ConstantReader(annotation);
  final formName = reader.read('name').stringValue.trim();
  if (formName.isEmpty) {
    throw Exception('name property of @FormClass cannot be empty.');
  }

  List<_FormPageInfo> pageInfos = _extractFormPagesInfo(annotation, 'does-not-matter');
  // pages cannot be empty must have at least one page
  if (pageInfos.isEmpty) {
    throw Exception('@FormClass() annotation must have at least one page in its definition.');
  }

  // page names should not be blank
  for (var page in pageInfos) {
    if (page.name.trim().isEmpty) {
      throw Exception('pages defined in @FormClass cannot have empty names.');
    }

    if (page.items.isEmpty) {
      throw Exception('pages defined in @FormClass must have at least 1 InputData item defined.');
    }
  }

  // input-data names should not be blank
  final inputDataInfos = pageInfos.map((e) => e.items).flattened;
  for (var inputData in inputDataInfos) {
    if (inputData.name.trim().isEmpty) {
      throw Exception('InputData objects defined in pages in @FormClass cannot have empty names.');
    }
  }
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

    final pageArgsClassName = '${pageName.pascalCase.removeSuffix('page')}Page';
    final argsClassPrivateVarName = '_${pageArgsClassName.camelCase}Args';

    for (var inputInfo in reader.read('items').listValue) {
      final reader = ConstantReader(inputInfo);
      final inputName = reader.read('name').stringValue;
      final inputType = reader.read('inputType').typeValue;
      final valueType = reader.read('valueType').typeValue;

      inputInfos.add(
        _InputDataInfo(
          name: inputName,
          pageArgsClassName: pageArgsClassName,
          argsClassPrivateVarName: argsClassPrivateVarName,
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
      argsClassName: pageArgsClassName,
      argsClassPrivateVarName: argsClassPrivateVarName,
      pageIndex: i,
    ));
  }

  return pages;
}

class _InputDataInfo {
  const _InputDataInfo({
    required this.name,
    required this.pageArgsClassName,
    required this.argsClassPrivateVarName,
    required this.formContextClassName,
    required this.inputType,
    required this.valueType,
  });

  final String name;
  final String pageArgsClassName;
  final String formContextClassName;
  final String argsClassPrivateVarName;
  final DartType inputType;
  final DartType valueType;

  String get dataType => 'InputData<${inputType.displayNameWithNullability}, ${valueType.displayNameWithNullability}>';

  String toInstantiateInputDataCode() {
    return '''
    $dataType(
      name: "$name",
      hint: $argsClassPrivateVarName.${argsClassName.camelCase}.hint,
      value: $argsClassPrivateVarName.${argsClassName.camelCase}.initialValue,
      input: $argsClassPrivateVarName.${argsClassName.camelCase}.initialInput,
      isOptional: $argsClassPrivateVarName.${argsClassName.camelCase}.isOptional,
      operation: $argsClassPrivateVarName.${argsClassName.camelCase}.operation,
      failure: $argsClassPrivateVarName.${argsClassName.camelCase}.failure,
      sideEffects: $argsClassPrivateVarName.${argsClassName.camelCase}.sideEffects,
      validator: (${inputType.displayNameWithNullability}? input) => $argsClassPrivateVarName.${argsClassName.camelCase}.validate${name.pascalCase}(formContext, input),
      onSubmit: ($dataType data) => $argsClassPrivateVarName.${argsClassName.camelCase}.onSubmit${name.pascalCase}(formContext, data),
    )
    ''';
  }

  String toArgsClassCode() {
    final inputTypeString = inputType.displayNameWithNullability;
    final valueTypeString = valueType.displayNameWithNullability;

    return '''
    class $argsClassName {
      $argsClassName({
        required this.validate${name.pascalCase},
        required this.onSubmit${name.pascalCase},
        this.isOptional = false,
        this.hint,
        this.initialValue,
        this.initialInput,
        this.operation,
        this.failure,
        this.sideEffects,
      });

      final Operation? operation;
      final Failure? failure;
      final List<dynamic>? sideEffects;
      final bool isOptional;
      final String? hint;
      final $valueTypeString? initialValue;
      final $inputTypeString? initialInput;
      final InputValidationResult Function($formContextClassName formContext, $inputTypeString? input) validate${name.pascalCase};
      final Future<void> Function($formContextClassName formContext, $dataType data) onSubmit${name.pascalCase};
    }

    ''';
  }

  String get argsClassName => '${name.pascalCase}InputData';
}

class _FormPageInfo {
  const _FormPageInfo({
    required this.name,
    required this.formContextClassName,
    required this.items,
    required this.submitResultType,
    required this.pageIndex,
    required this.argsClassName,
    required this.argsClassPrivateVarName,
  });

  final String name;
  final String formContextClassName;
  final String argsClassName;
  final String argsClassPrivateVarName;
  final String submitResultType;
  final List<_InputDataInfo> items;
  final int pageIndex;

  String get submitMethodName => 'submit${nameWithPageExtension.pascalCase}';
  String get onSubmitMethodName => 'onSubmitPage';
  String get submitValuesCallbackArgsClassName => '${nameWithPageExtension.pascalCase}SubmitValueArgs';

  String get nameWithPageExtension => name.addSuffix('Page');

  String get contextClassName => '${name.pascalCase}Context';
  String get contextClassInstanceVarName => nameWithPageExtension;

  String toFormArgumentsClassCode() {
    final buffer = StringBuffer();
    buffer.writeln('// custom class code for $argsClassName');

    buffer.writeln('class $argsClassName {'); // start of class
    // constructor
    final inputArgs = items.map((e) => "required this.${e.argsClassName.camelCase}").join(',').trim();
    buffer.writeln(
        '$argsClassName({ ${inputArgs.isNotEmpty ? "$inputArgs," : ""} required this.$onSubmitMethodName });\n');

    // input properties
    for (var inputInfo in items) {
      buffer.writeln('final ${inputInfo.argsClassName} ${inputInfo.argsClassName.camelCase};');
    }

    // other properties
    buffer.writeln('final pageIndex = $pageIndex;');

    // onSubmit property
    buffer.writeln(
      'final Future<void> Function($formContextClassName formContext, Data<$submitResultType> submitResult, $submitValuesCallbackArgsClassName args) $onSubmitMethodName;',
    );

    buffer.writeln('}'); // end of class

    for (var inputInfo in items) {
      buffer.writeln(inputInfo.toArgsClassCode());
    }
    return buffer.toString();
  }

  String toContextClassCode() {
    return '''
      class $contextClassName {
        $contextClassName(this._pages, this.index);
        final List<FormPage> _pages;
        final int index;

        final submitResult = Data<$submitResultType>();

        ${items.mapIndexed((inputItemIndex, e) {
      return '${e.dataType} get ${e.name} => _pages[index].items[$inputItemIndex] as ${e.dataType};';
    }).join('\n')}
      }
    ''';
  }

  String toOnSubmitCallbackArgumentsClass() {
    return '''
    class $submitValuesCallbackArgsClassName {
      $submitValuesCallbackArgsClassName(${items.map((e) => 'this.${e.name}').join(',')});

      ${items.map((e) => 'final ${e.valueType.displayNameWithNullability} ${e.name};').join('\n')}
    }
    ''';
  }
}

class SubmitMethodInfo {
  SubmitMethodInfo({
    required this.submitResultGetter,
    required this.method,
    required this.pageName,
    required this.alwaysRetry,
  });

  final String submitResultGetter;
  final String method;
  final String pageName;
  final bool alwaysRetry;
}
