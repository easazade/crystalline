import 'package:build/build.dart';
import 'package:crystalline_builder/src/builder.dart';
import 'package:crystalline_builder/src/unified_builder.dart';

Builder crystallineBuilder(BuilderOptions options) {
  return CrystallineBuilder();
}

Builder unifiedCrystallineBuilder(BuilderOptions options) {
  return UnifiedCrystallineBuilder();
}
