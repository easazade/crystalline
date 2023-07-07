import 'package:crystalline/src/utils.dart';

class Failure {
  Failure(this.message, {this.id, this.exception, this.stacktrace});

  final String message;
  final String? id;
  final dynamic exception;
  final StackTrace? stacktrace;

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write(inRed('Failure: '));

    if (id != null) {
      buffer.write(inRed('id: $id,'));
    }

    buffer.writeln(inRed(' message: $message'));

    if (exception != null) {
      buffer.writeln(inRed(exception));
    }

    if (stacktrace != null) {
      buffer.writeln(inRed(stacktrace));
    }

    return buffer.toString();
  }
}
