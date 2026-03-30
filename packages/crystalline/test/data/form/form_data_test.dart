import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../../test_utils/test_logger.dart';

part 'form_data_test.crystalline.dart';

@FormClass(name: 'login-form', pages: [
  FormPageInfo(
    name: 'credentials',
    items: [
      InputDataInfo(name: 'email', inputType: String, valueType: String),
      InputDataInfo(name: 'password', inputType: String, valueType: String),
    ],
    submitResultType: bool,
  ),
  FormPageInfo(
    name: 'verification',
    items: [
      InputDataInfo(name: 'code', inputType: String, valueType: int),
    ],
    submitResultType: bool,
  ),
  FormPageInfo(
    name: 'last-page',
    items: [],
    submitResultType: bool,
  ),
])
class _LoginForm {}

void main() {
  late LoginForm loginForm;
  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    loginForm = LoginForm(
      credentialsPageArgs: CredentialsPageArgs(
        emailInputData: EmailInputData(
          validateEmail: (formContext, input) {
            if (input != null && input.endsWith('@gmail.com')) {
              return InputValidationResult.valid();
            } else {
              return InputValidationResult.error(Failure('Only gmails are accepted]'));
            }
          },
          onSubmitEmail: (formContext, email) async => email.value = email.input,
        ),
        passwordInputData: PasswordInputData(
          validatePassword: (formContext, input) {
            if (input == null || input.trim().isEmpty) {
              return InputValidationResult.error(Failure('please enter a password'));
            } else if (input.length >= 8) {
              return InputValidationResult.valid();
            } else {
              return InputValidationResult.error(Failure('password is to weak'));
            }
          },
          onSubmitPassword: (formContext, password) async => password.value = password.input,
        ),
        onSubmitPage: (formContext, submitResult, email, password) async {
          // do something
          submitResult.value = true;
        },
      ),
      verificationPageArgs: VerificationPageArgs(
        codeInputData: CodeInputData(
          validateCode: (formContext, input) {
            if (input != null && input.length == 4 && int.tryParse(input) != null) {
              return InputValidationResult.valid();
            } else {
              return InputValidationResult.error(Failure('verification code must be 4 digits'));
            }
          },
          onSubmitCode: (formContext, code) async => code.value = int.tryParse(code.input),
        ),
        onSubmitPage: (formContext, submitResult, code) async {
          // do something, send request to api and set result on submitData
          submitResult.value = true;
        },
      ),
      lastPagePageArgs: LastPagePageArgs(onSubmitPage: (formContext, submitResult) async {
        // do something, send request to api and set result on submitData
        submitResult.value = true;
      }),
    );
  });

  group('items', () {
    test('form data should be updated when InputData items get updated', () {});
  });
}
