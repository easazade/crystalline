class Failure {
  Failure(this.message, {this.id, this.exception});

  final String message;
  final String? id;
  final dynamic exception;

  @override
  String toString() => '${id != null ? "error-id: $id -> " : ""}$message\n'
      '${exception != null ? exception : ""}\n'
      '${super.toString()}';
}
