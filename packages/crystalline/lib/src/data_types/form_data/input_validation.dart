part of 'form_data.dart';

enum InputValidationState { validated, invalid, ignore }

class InputValidationResult {
  Failure? failure;
  final InputValidationState state;

  InputValidationResult._(this.state, this.failure);

  factory InputValidationResult.valid() => InputValidationResult._(InputValidationState.validated, null);

  factory InputValidationResult.error(Failure failure) =>
      InputValidationResult._(InputValidationState.invalid, failure);

  factory InputValidationResult.neutral() => InputValidationResult._(InputValidationState.ignore, null);

  bool get isValid => state == InputValidationState.validated;

  bool get hasFailure => state == InputValidationState.invalid;

  bool get isNeutral => state == InputValidationState.ignore;
}
