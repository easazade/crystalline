import 'data_types/data.dart';

class ValueNotAvailableException implements Exception {
  const ValueNotAvailableException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'Data has no value please check for availability of value in Data before calling value\n'
        'this can be done by calling `hasValue` getter method first'
        '\n';
  }
}

class OperationNotAvailableException implements Exception {
  const OperationNotAvailableException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'Data has no operation please check for availability of operation in Data before calling value\n'
        'this can be done by calling `hasAnyOperation` getter method first'
        '\n';
  }
}

class FailureIsNullException implements Exception {
  const FailureIsNullException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'Data has no failure please check if Data has failure first\n'
        'this can be done by calling `hasFailure` getter method first'
        '\n';
  }
}

class ContextIsNullException implements Exception {
  const ContextIsNullException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'ContextData has no context please check if ContextData has context first\n'
        'this can be done by calling `hasContext` getter method first\n'
        'Alternatively you can use `contextOrNull`';
  }
}

class InputIsNullException implements Exception {
  const InputIsNullException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'InputData has no input please check if InputData has input first\n'
        'this can be done by calling `hasInput` getter method first\n'
        'Alternatively you can use `inputOrNull`';
  }
}

class CannotUpdateFromTypeException implements Exception {
  const CannotUpdateFromTypeException(this.source, this.other);

  final Data<dynamic> source;
  final Data<dynamic> other;

  @override
  String toString() {
    return '${super.toString()}\n'
        'Cannot update type ${source.runtimeType} from type ${other.runtimeType}'
        'Because they are different types';
  }
}
