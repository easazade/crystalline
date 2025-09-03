import 'dart:developer' as dev;

import 'package:crystalline/src/config/logger/crystalline_logger.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:meta/meta.dart';

class DefaultCrystallineLogger extends CrystallineLogger {
  String redText(dynamic object) => "\x1B[31m${object}\x1B[0m";

  String greenText(dynamic object) => "\x1B[32m${object}\x1B[0m";

  String yellowText(dynamic object) => "\x1B[33m${object}\x1B[0m";

  String orangeText(dynamic object) => "\x1B[34m${object}\x1B[0m";

  String magentaText(dynamic object) => "\x1B[35m${object}\x1B[0m";

  String cyanText(dynamic object) => "\x1B[36m${object}\x1B[0m";

  String whiteText(dynamic object) => "\x1B[37m${object}\x1B[0m";

  String whiteTextRedBg(dynamic object) => '\x1B[41m\x1B[37m${object}\x1B[0m';

  String whiteTextBlueBg(dynamic object) => '\x1B[44m\x1B[37m${object}\x1B[0m';

  String resetTextColors(dynamic object) => "\x1B[0m${object}\x1B[0m";

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
      buffer.write('${yellowText(data.name)}:');
    }
    buffer.write('${data.runtimeType} = ');
    if (data.hasFailure) {
      buffer.write("failure: ${redText('<')}");
      if (data.failureOrNull?.id != null) {
        buffer.write(redText('id: ${data.failure.id} - '));
      }
      if (data.failureOrNull?.cause != null) {
        buffer.write(redText('cause: ${data.failure.cause} - '));
      }
      buffer.write(
        '${redText("${ellipsize(data.failure.message, maxSize: 20)}> ")}| ',
      );
    }

    if (data.operation == Operation.none) {
      buffer.write('operation: ${data.operation.name}');
    } else {
      buffer.write('operation: ${whiteTextBlueBg(data.operation.name)}');
    }

    if (data.hasValue) {
      buffer.write(' | value: ${greenText(data.valueOrNull)}');
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

    buffer.write(redText('Failure: '));

    if (failure.id != null) {
      buffer.write(redText('id: ${failure.id},'));
    }

    buffer.writeln(whiteTextRedBg(' message: ${failure.message}'));

    if (failure.exception != null) {
      buffer.writeln(redText(failure.exception));
    }

    if (failure.stacktrace != null) {
      buffer.writeln(redText(failure.stacktrace));
    }

    return buffer.toString();
  }

  @override
  String? globalLogFilter(Data<dynamic> data) => data.toString();

  @override
  void log(dynamic object) {
    dev.log(object.toString());
  }
}
