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

class ErrorIsNullException implements Exception {
  const ErrorIsNullException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'Data has no error please check if Data has error first\n'
        'this can be done by calling `hasError` getter method first'
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
        'Alternativly you can use `contextOrNull`'
        '\n';
  }
}

class CannotUpdateFromTypeException implements Exception {
  const CannotUpdateFromTypeException(this.source, this.other);

  final ReadableData<dynamic> source;
  final ReadableData<dynamic> other;

  @override
  String toString() {
    return '${super.toString()}\n'
        'Cannot update type ${source.runtimeType} from type ${other.runtimeType}'
        'Because they are different types';
  }
}
