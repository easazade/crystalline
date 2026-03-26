part of 'form_data.dart';


enum InputValidationState { validated, invalid, ignore }

class InputValidation {
  Failure? failure;
  final InputValidationState state;

  InputValidation._(this.state, this.failure);

  factory InputValidation.valid() => InputValidation._(InputValidationState.validated, null);

  factory InputValidation.error(String message) => InputValidation._(InputValidationState.invalid, Failure(message));

  factory InputValidation.neutral() => InputValidation._(InputValidationState.ignore, null);

  bool get isValid => state == InputValidationState.validated;

  bool get hasFailure => state == InputValidationState.invalid;

  bool get isNeutral => state == InputValidationState.ignore;
}
