import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/semantics/operation.dart';

class Failure {
  Failure(this.message, {this.id, this.cause, this.exception, this.stacktrace});

  final String message;
  final String? id;
  final Operation? cause;
  final dynamic exception;
  final StackTrace? stacktrace;

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForFailure(this);
}
