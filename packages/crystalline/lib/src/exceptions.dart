class ValueNotAvailableException implements Exception {
  const ValueNotAvailableException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'Data has no value please check for availability of value in Data before calling value\n'
        'this can be done by calling `isAvailable` getter method first'
        '\n';
  }
}

class DataErrorIsNullException implements Exception {
  const DataErrorIsNullException();

  @override
  String toString() {
    return '${super.toString()}\n'
        'Data has no error please check if Data has error first\n'
        'this can be done by calling `hasError` getter method first'
        '\n';
  }
}
