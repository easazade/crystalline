part of 'form_data.dart';

class InputData<INPUT, OUTPUT> extends Data<OUTPUT> {
  InputData({
    super.value,
    INPUT? input,
    super.failure,
    super.operation,
    List<dynamic>? super.sideEffects,
    this.validator,
    required this.onSubmit,
    super.name,
    String? hint,
  })  : _input = input,
        _hint = hint;

  INPUT? _input;
  String? _hint;
  final InputValidationResult Function(INPUT input)? validator;
  final Future<void> Function(InputData<INPUT, OUTPUT> data) onSubmit;

  set hint(String? hint) {
    _hint = hint;
    notifyObserversAndStreamListeners();
  }

  String? get hint => _hint;

  bool get hasInput => _input != null;

  set input(INPUT? input) {
    _input = input;

    if (input != null && validator != null) {
      disallowNotify();
      final validation = validator!.call(input);
      if (validation.hasFailure) {
        var failureObject = validation.failure;
        if (failureObject!.type == null) {
          failureObject = failureObject.copyWith(type: FailureType.hint);
        }
        failure = failureObject;
      } else if (validation.isValid || validation.isNeutral) {
        failure = null;
      }
      allowNotify();
    }

    notifyObserversAndStreamListeners();
  }

  INPUT get input {
    if (_input == null) {
      throw InputIsNullException();
    }
    return _input!;
  }

  INPUT? get inputOrNull => _input;

  Future<void> submit({
    final Future<void> Function(InputData<INPUT, OUTPUT> input)? overrideOnSubmit,
  }) async {
    if (validator != null && hasInput) {
      final validation = validator!.call(input);
      if (validation.hasFailure) {
        var failureObject = validation.failure;
        if (failureObject!.type == null) {
          failureObject = failureObject.copyWith(type: FailureType.error);
        }
        failure = failureObject;
      }
    }

    final callback = overrideOnSubmit ?? onSubmit;

    await callback(this);

    if (hasFailure && failure.type == null) {
      failure = failure.copyWith(type: FailureType.error);
    } else if (hasNoValue && !hasFailure) {
      failure = Failure('! No value or failure resolved on submit', type: FailureType.error);
    }
  }

  @override
  void modify(void Function(InputData<INPUT, OUTPUT> data) fn) {
    super.modify((data) => fn(data as InputData<INPUT, OUTPUT>));
  }

  @override
  Future<void> modifyAsync(Future<void> Function(InputData<INPUT, OUTPUT> data) fn) {
    return super.modifyAsync((data) => fn(data as InputData<INPUT, OUTPUT>));
  }

  @override
  void updateFrom(Data<OUTPUT> data) {
    if (data is! InputData<INPUT, OUTPUT>) {
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
  InputData<INPUT, OUTPUT> copy() => InputData<INPUT, OUTPUT>(
        value: valueOrNull,
        failure: failureOrNull,
        operation: operationOrNull,
        input: inputOrNull,
        hint: _hint,
        name: name,
        validator: validator,
        onSubmit: onSubmit,
        sideEffects: sideEffects.all.toList(),
      );

  @override
  Stream<InputData<INPUT, OUTPUT>> get stream => streamController.stream.map((e) => this);

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (other is! InputData<INPUT, OUTPUT>) return false;

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
