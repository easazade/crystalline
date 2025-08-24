import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';

extension DartFormatterX on DartFormatter {
  String tryFormat(String input) {
    try {
      return format(input);
    } catch (e) {
      print('Failed to Format');
      return input;
    }
  }
}

extension DartTypeX on DartType {
  String? get displayNameWithNullability {
    final type = element3?.displayName;
    if (type == null) {
      return null;
    } else {
      return nullabilitySuffix == NullabilitySuffix.question ? '$type?' : type;
    }
  }
}

extension AssetIdX on AssetId {
  String get importLine {
    return "import '${uri.toString()}';";
  }
}
