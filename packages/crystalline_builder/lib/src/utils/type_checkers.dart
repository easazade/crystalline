import 'package:crystalline/crystalline.dart';
import 'package:source_gen/source_gen.dart';

final sharedDataTypeChecker = TypeChecker.typeNamed(SharedData);
final storeTypeChecker = TypeChecker.typeNamed(StoreClass);
final customSideEffectTypeChecker = TypeChecker.typeNamed(CustomSideEffect);
