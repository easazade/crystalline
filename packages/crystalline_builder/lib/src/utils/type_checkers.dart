import 'package:crystalline/crystalline.dart';
import 'package:source_gen/source_gen.dart';

final sharedDataTypeChecker = TypeChecker.typeNamed(SharedData);
final storeClassTypeChecker = TypeChecker.typeNamed(StoreClass);
final formClassTypeChecker = TypeChecker.typeNamed(FormClass);
final formDataTypeChecker = TypeChecker.typeNamed(FormData);
final customSideEffectTypeChecker = TypeChecker.typeNamed(CustomSideEffect);
