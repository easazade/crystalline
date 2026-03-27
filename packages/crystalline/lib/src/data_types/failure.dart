import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/semantics/operation.dart';

class _FailureCopyWithUnset {
  const _FailureCopyWithUnset();
}

const _failureCopyWithUnset = _FailureCopyWithUnset();

class Failure {
  Failure(this.message, {this.id, this.cause, this.exception, this.stacktrace, this.type});

  final String message;
  final String? id;
  final Operation? cause;
  final dynamic exception;
  final StackTrace? stacktrace;
  final FailureType? type;

  Failure copyWith({
    String? message,
    Object? id = _failureCopyWithUnset,
    Object? cause = _failureCopyWithUnset,
    Object? exception = _failureCopyWithUnset,
    Object? stacktrace = _failureCopyWithUnset,
    Object? type = _failureCopyWithUnset,
  }) {
    return Failure(
      message ?? this.message,
      id: identical(id, _failureCopyWithUnset) ? this.id : id as String?,
      cause: identical(cause, _failureCopyWithUnset) ? this.cause : cause as Operation?,
      exception: identical(exception, _failureCopyWithUnset) ? this.exception : exception,
      stacktrace: identical(stacktrace, _failureCopyWithUnset) ? this.stacktrace : stacktrace as StackTrace?,
      type: identical(type, _failureCopyWithUnset) ? this.type : type as FailureType?,
    );
  }

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForFailure(this);
}

enum FailureType { hint, error }
