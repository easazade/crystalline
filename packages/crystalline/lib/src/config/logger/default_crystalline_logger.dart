import 'package:crystalline/src/config/logger/crystalline_logger.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:meta/meta.dart';

class DefaultCrystallineLogger extends CrystallineLogger {
  String inRed(dynamic object) => "\x1B[31m${object}\x1B[0m";

  String inGreen(dynamic object) => "\x1B[32m${object}\x1B[0m";

  String inYellow(dynamic object) => "\x1B[33m${object}\x1B[0m";

  String inOrange(dynamic object) => "\x1B[34m${object}\x1B[0m";

  String inMagenta(dynamic object) => "\x1B[35m${object}\x1B[0m";

  String inCyan(dynamic object) => "\x1B[36m${object}\x1B[0m";

  String inWhite(dynamic object) => "\x1B[37m${object}\x1B[0m";

  String inReset(dynamic object) => "\x1B[0m${object}\x1B[0m";

  String inBlinking(dynamic object) => "\x1B[5m${object}\x1B[0m";

  String inBlinkingFast(dynamic object) => "\x1B[6m${object}\x1B[0m";

  /// prints all ANSI colors and effects that can be shown
  /// this method is just for testing to see what colors/effects we can use
  @visibleForTesting
  void printAllColorsAndEffects() {
    for (var i = 0; i < 110; i++) {
      print("$i -> \x1B[${i}m${'Hello'}\x1B[0m");
    }
  }

  String ellipsize(String text, {required int maxSize}) {
    if (text.length <= maxSize) {
      return text;
    } else {
      return '${text.substring(0, maxSize)}...';
    }
  }

  String generateToStringForData<T>(Data<T> data) {
    final buffer = StringBuffer();
    buffer.write('{ ');
    if (data.name != null) {
      buffer.write('${inYellow(data.name)}:');
    }
    buffer.write('${inYellow(data.runtimeType)} = ');
    if (data.hasFailure) {
      buffer.write("failure: ${inRed('<')}");
      if (data.failureOrNull?.id != null) {
        buffer.write(inRed('id: ${data.failure.id} - '));
      }
      if (data.failureOrNull?.cause != null) {
        buffer.write(inRed('cause: ${data.failure.cause} - '));
      }
      buffer.write(
          '${inRed("${ellipsize(data.failure.message, maxSize: 20)}> ")}| ');
    }

    if (data.operation == Operation.none) {
      buffer.write('operation: ${data.operation.name}');
    } else {
      buffer.write('operation: ${inBlinking(inMagenta(data.operation.name))}');
    }

    if (data.hasValue) {
      buffer.write(' | value: ${inGreen(data.valueOrNull)}');
    } else {
      buffer.write(' | value: ${data.valueOrNull}');
    }

    buffer.writeln(' }');

    if (data.failureOrNull != null) {
      buffer.write(data.failure.toString());
    }

    return buffer.toString();
  }

  @override
  String generateToStringForFailure(Failure failure) {
    final buffer = StringBuffer();

    buffer.write(inRed('Failure: '));

    if (failure.id != null) {
      buffer.write(inRed('id: ${failure.id},'));
    }

    buffer.writeln(inRed(' message: ${failure.message}'));

    if (failure.exception != null) {
      buffer.writeln(inRed(failure.exception));
    }

    if (failure.stacktrace != null) {
      buffer.writeln(inRed(failure.stacktrace));
    }

    return buffer.toString();
  }

  @override
  String? globalLogFilter(Data<dynamic> data) => data.toString();

  @override
  void log(dynamic object) {
    print(object);
  }
}
