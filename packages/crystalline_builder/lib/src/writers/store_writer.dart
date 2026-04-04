import 'package:analyzer/dart/element/element.dart';
import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:crystalline_builder/src/utils/functions.dart';
import 'package:crystalline_builder/src/utils/type_checkers.dart';
import 'package:source_gen/source_gen.dart';

void writeStoreClass(final StringBuffer buffer, final LibraryElement library) {
  for (var cls in library.classes) {
    if (!storeClassTypeChecker.hasAnnotationOfExact(cls)) continue;
    validateSourceSyntaxForStoreAnnotatedClass(cls);

    final storeAnnotation = storeClassTypeChecker.firstAnnotationOfExact(cls);
    // nothing to read from annotation for now
    // ignore: unused_local_variable
    final reader = ConstantReader(storeAnnotation);

    final className = cls.displayName;
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

    final ctorParams = cls.unnamedConstructor!.formalParameters;
    final copyCtorPositionalArgs = ctorParams.where((p) => p.isPositional).map((p) => p.displayName).join(', ');
    final copyCtorNamedArgs =
        ctorParams.where((p) => p.isNamed).map((p) => '${p.displayName}: ${p.displayName}').join(', ');
    final copyCtorInvocation = () {
      if (copyCtorPositionalArgs.isEmpty && copyCtorNamedArgs.isEmpty) {
        return '$storeClassName()';
      }
      if (copyCtorPositionalArgs.isNotEmpty && copyCtorNamedArgs.isEmpty) {
        return '$storeClassName($copyCtorPositionalArgs)';
      }
      if (copyCtorPositionalArgs.isEmpty && copyCtorNamedArgs.isNotEmpty) {
        return '$storeClassName($copyCtorNamedArgs)';
      }
      return '$storeClassName($copyCtorPositionalArgs, $copyCtorNamedArgs)';
    }();

    buffer.writeln(
      '''
        $sharedPropertiesPart

        class $storeClassName extends $className {
          // constructor
          $storeClassName(
            ${positionalParams.isNotEmpty ? "$positionalParams, " : ""}
            ${namedParams.isNotEmpty ? "{$namedParams}" : ""}
          );

          $storeClassSharedPropertiesPart

          @override
          List<Data<Object?>> get states => [${dataProperties.map((e) => e.displayName).join(',')}];

          @override
          String? get name => '$storeClassName';

          @override
          bool operator ==(Object other) {
            if (other is! $storeClassName) return false;

            return other.runtimeType == runtimeType &&
                failureOrNull == other.failureOrNull &&
                operationOrNull == other.operationOrNull &&
                const ListEquality().equals(sideEffects.all.toList(), other.sideEffects.all.toList()) &&
                const ListEquality().equals(states, other.states);
          }

          @override
          int get hashCode => Object.hashAll([
                failureOrNull,
                sideEffects.all,
                states,
                operationOrNull,
                runtimeType,
              ]);

                  
          @override
          Stream<$storeClassName> get stream => streamController.stream.map((e) => this);

          @override
          Stream<$storeClassName> streamWith({
            bool skipUntilInitialized = false,
            bool skipOperations = false,
          }) {
            Stream<$storeClassName> stream = streamController.stream.map((e) => this);

            if (skipUntilInitialized) {
              stream = _streamWithSkipUntilInitialized();
            }

            if (skipOperations) {
              stream = stream.skipWhile((e) => e.hasAnyOperation);
            }

            return stream;
          }

          Stream<$storeClassName> _streamWithSkipUntilInitialized() {
            var hadSkippedEmission = false;
            final sc = StreamController<$storeClassName>(sync: true);
            StreamSubscription<bool>? streamSub;

            sc.onListen = () {
              streamSub = streamController.stream.listen((_) {
                if (isInitialized) {
                  if (!sc.isClosed) sc.add(this);
                } else {
                  hadSkippedEmission = true;
                }
              });

              ensureInitialized().then((_) {
                if (hadSkippedEmission && !sc.isClosed) {
                  sc.add(this);
                }
              });
            };

            sc.onCancel = () => streamSub?.cancel();

            return sc.stream;
          }

          @override
          $storeClassName copy() {
            final result = $copyCtorInvocation;
            
            for (var i = 0; i < states.length; i++) {
              // ignore: avoid_dynamic_calls
              (result.states[i] as dynamic).updateFrom((states[i] as dynamic).copy());
            }
            result.operation = operationOrNull;
            result.failure = failureOrNull;
            result.sideEffects.clear();
            result.sideEffects.addAll(sideEffects.all);
            return result;
          }

          @override
          void updateFrom(Data<void> data) {
            // no need for calling disallowNotify(); since notifying is by default disallowed for all stores
            final old = copy();
            if (data is $storeClassName) {
              for (var i = 0; i < states.length; i++) {
                // ignore: avoid_dynamic_calls
                (states[i] as dynamic).updateFrom((data.states[i] as dynamic));
              }
            }
            value = data.valueOrNull;
            operation = data.operationOrNull;
            failure = data.failureOrNull;
            sideEffects.clear();
            sideEffects.addAll(data.sideEffects.all);

            if (old.operationOrNull != operationOrNull) {
              events.dispatch(OperationEvent(operationOrNull));
            }
            if (old.failureOrNull != failureOrNull && failureOrNull != null) {
              events.dispatch(FailureEvent(failure));
            }
            if (!const ListEquality<dynamic>().equals(
                  old.sideEffects.all.toList(),
                  sideEffects.all.toList(),
                )) {
              events.dispatch(SideEffectsUpdatedEvent(sideEffects.all));
            }

            publish();
          }          

        }
      ''',
    );

    // validate source syntax
    // add callback methods to the mixin
  }
}

void validateSourceSyntaxForStoreAnnotatedClass(ClassElement cls) {
  if (!cls.isPrivate || !cls.isAbstract) {
    throw Exception('!!! ->>> Annotated store classes with @StoreClass need to be private and abstract');
  }

  if (cls.unnamedConstructor == null) {
    throw Exception('!!! ->>> Annotated store classes with @StoreClass must have an unnamed constructor');
  }
}
