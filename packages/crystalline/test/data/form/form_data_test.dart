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
  )
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
          onSubmitEmail: (formContext, email) async {
            email.failure = null;
            email.operation = Operation.update;
            email.value = email.input;
            email.operation = null;
          },
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
          submitResult.operation = Operation('submit-form');
          await Future.delayed(const Duration(milliseconds: 200));
          // do something, send request to api and set result on submitData
          submitResult.value = true;
          submitResult.operation = null;
        },
      ),
    );
  });

  group('items', () {
    test(
      'form data should be updated when InputData items get updated',
      () {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        final email = loginForm[0] as InputData<String, String>;
        email.input = 'user@gmail.com';

        expect(formNotifications, 1);
        expect(email.inputOrNull, 'user@gmail.com');
        expect(email.hasFailure, isFalse);
      },
    );

    test(
      'form data should be notified when multiple InputData items get updated',
      () {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        final email = loginForm[0] as InputData<String, String>;
        final password = loginForm[1] as InputData<String, String>;

        email.input = 'user@gmail.com';
        password.input = 'longpassword';

        expect(formNotifications, 2);
        expect(email.inputOrNull, 'user@gmail.com');
        expect(email.hasFailure, isFalse);
        expect(password.inputOrNull, 'longpassword');
        expect(password.hasFailure, isFalse);
      },
    );

    test(
      'inputData item should set valid input and then form-data should be notified',
      () {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        final email = loginForm[0] as InputData<String, String>;
        email.input = 'not-valid-email';
        expect(email.hasFailure, isTrue);
        expect(formNotifications, 1);

        email.input = 'valid.address@gmail.com';
        expect(email.hasFailure, isFalse);
        expect(formNotifications, 2);
      },
    );

    test(
      'during input-data submit, form-data should get notified as many times the input data object gets updated',
      () async {
        final email = loginForm[0] as InputData<String, String>;
        email.input = 'commit@gmail.com';

        var formNotifications = 0;
        var itemNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));
        email.observers.add(Observer(() => itemNotifications++));

        await email.submit();
        expect(itemNotifications, 4);
        expect(formNotifications, 4);
      },
    );
  });
}
