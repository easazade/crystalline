part of 'form_data.dart';

class InputData<T, I> extends Data<T> {
  InputData({
    super.value,
    I? input,
    super.failure,
    super.operation,
    List<dynamic>? super.sideEffects,
    this.validator,
    super.name,
    String? hint,
  })  : _input = input,
        _hint = hint;

  I? _input;
  String? _hint;
  final InputValidation Function(I input)? validator;

  set hint(String? hint) {
    _hint = hint;
    notifyObserversAndStreamListeners();
  }

  String? get hint => _hint;

  bool get hasInput => _input != null;

  set input(I? input) {
    _input = input;

    if (input != null && validator != null) {
      disallowNotify();
      final validation = validator!.call(input);
      if (validation.hasFailure) {
        failure = validation.failure;
      } else if (validation.isValid || validation.isNeutral) {
        failure = null;
      }
      allowNotify();
    }

    notifyObserversAndStreamListeners();
  }

  I get input {
    if (_input == null) {
      throw InputIsNullException();
    }
    return _input!;
  }

  I? get inputOrNull => _input;

  @override
  void modify(void Function(InputData<T, I> data) fn) {
    super.modify((data) => fn(data as InputData<T, I>));
  }

  @override
  Future<void> modifyAsync(Future<void> Function(InputData<T, I> data) fn) {
    return super.modifyAsync((data) => fn(data as InputData<T, I>));
  }

  @override
  void updateFrom(Data<T> data) {
    if (data is! InputData<T, I>) {
      throw CannotUpdateFromTypeException(this, data);
    }
    disallowNotify();
    value = data.valueOrNull;
    operation = data.operationOrNull;
    failure = data.failureOrNull;
    input = data.input;
    hint = data.hint;
    sideEffects.clear();
    sideEffects.addAll(data.sideEffects.all);
    allowNotify();
    notifyObserversAndStreamListeners();
  }

  @override
  void reset() {
    _input = null;
    _hint = null;
    super.reset();
  }

  @override
  InputData<T, I> copy() => InputData<T, I>(
        value: valueOrNull,
        failure: failureOrNull,
        operation: operationOrNull,
        input: inputOrNull,
        hint: _hint,
        name: name,
        validator: validator,
        sideEffects: sideEffects.all.toList(),
      );

  @override
  Stream<InputData<T, I>> get stream => streamController.stream.map((e) => this);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (other is! InputData<T, I>) return false;

    return other.runtimeType == runtimeType &&
        failureOrNull == other.failureOrNull &&
        valueOrNull == other.valueOrNull &&
        inputOrNull == other.inputOrNull &&
        operationOrNull == other.operationOrNull &&
        ListEquality().equals(sideEffects.all.toList(), other.sideEffects.all.toList());
  }

  @override
  @mustBeOverridden
  int get hashCode => Object.hashAll([
        failureOrNull,
        valueOrNull,
        inputOrNull,
        sideEffects.all,
        operationOrNull,
        runtimeType,
      ]);
}
