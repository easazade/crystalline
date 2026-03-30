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
  String? get displayName => element?.displayName;

  String? get displayNameWithNullability {
    final type = element?.displayName;
    if (type == null) {
      return null;
    } else {
      return nullabilitySuffix == NullabilitySuffix.question ? '$type?' : type;
    }
  }

  String get displayNameWithGenericTypes {
    var value = '$displayName';
    final genericArgs = (this as InterfaceType).typeArguments;
    if (genericArgs.isNotEmpty) {
      value = '$value<${genericArgs.join(',')}>';
    }
    return value;
  }
}

extension AssetIdX on AssetId {
  String get importLine {
    return "import '${uri.toString()}';";
  }
}

extension StringX on String {
  /// Removes [suffix] from the end of this string when it matches there.
  /// Matching is case-insensitive (Pascal, camel, ALL CAPS, etc.).
  ///
  /// The result is trimmed. If trimming yields an empty string, or a string
  /// that is not a valid Dart identifier (for generated classes, variables,
  /// or functions), returns this string unchanged.
  ///
  /// Trailing whitespace is ignored when checking for [suffix] at the end, so
  /// e.g. `'LoginPage  '` still strips `'page'` to `'Login'`.
  ///
  /// If [suffix] is empty, or the string does not end with [suffix] (ignoring
  /// case), returns this string unchanged.
  String removeSuffix(String suffix) {
    if (suffix.isEmpty) return this;
    final end = trimRight();
    if (!_endsWithIgnoreCase(end, suffix)) return this;
    final result = end.substring(0, end.length - suffix.length).trim();
    if (result.isEmpty || !_isValidDartIdentifier(result)) {
      return this;
    }
    return result;
  }

  String addSuffixIfNotEmpty(String suffix) {
    if (trim().isNotEmpty) {
      return '$this$suffix';
    } else {
      return this;
    }
  }
}

bool _endsWithIgnoreCase(String value, String suffix) {
  if (value.length < suffix.length) return false;
  final start = value.length - suffix.length;
  return value.substring(start).toLowerCase() == suffix.toLowerCase();
}

/// Whether [name] is a valid simple Dart identifier (ASCII letters, digits,
/// `_`, `$`), suitable for codegen output.
bool _isValidDartIdentifier(String name) {
  return RegExp(r'^[a-zA-Z_$][a-zA-Z0-9_$]*$').hasMatch(name);
}
