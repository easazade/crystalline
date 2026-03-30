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

LoginForm createLoginForm({
  Future<void> Function(
    LoginFormContext formContext,
    Data<bool> submitResult,
    String email,
    String password,
  )? onSubmitCredentialsPage,
  Future<void> Function(
    LoginFormContext formContext,
    Data<bool> submitResult,
    int code,
  )? onSubmitVerificationPage,
}) {
  return LoginForm(
    credentialsPageArgs: CredentialsPageArgs(
      emailInputDataArgs: EmailInputDataArgs(
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
      passwordInputDataArgs: PasswordInputDataArgs(
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
      onSubmitPage: onSubmitCredentialsPage ??
          (formContext, submitResult, email, password) async {
            submitResult.value = true;
          },
    ),
    verificationPageArgs: VerificationPageArgs(
      codeInputDataArgs: CodeInputDataArgs(
        validateCode: (formContext, input) {
          if (input != null && input.length == 4 && int.tryParse(input) != null) {
            return InputValidationResult.valid();
          } else {
            return InputValidationResult.error(Failure('verification code must be 4 digits'));
          }
        },
        onSubmitCode: (formContext, code) async => code.value = int.tryParse(code.input),
      ),
      onSubmitPage: onSubmitVerificationPage ??
          (formContext, submitResult, code) async {
            submitResult.operation = Operation('submit-form');
            await Future.delayed(const Duration(milliseconds: 200));
            submitResult.value = true;
            submitResult.operation = null;
          },
    ),
  );
}

void main() {
  late LoginForm loginForm;
  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  setUp(() {
    loginForm = createLoginForm();
  });

  group('items -', () {
    test(
      'form data should be updated when InputData items get updated',
      () {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        final email = loginForm.credentialsPage.email;
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

        final email = loginForm.credentialsPage.email;
        final password = loginForm.credentialsPage.password;

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

        final email = loginForm.credentialsPage.email;
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
        final email = loginForm.credentialsPage.email;
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

    test(
      'verification page InputData updates notify the form',
      () {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        loginForm.verificationPage.code.input = '1234';
        expect(formNotifications, 1);
        expect(loginForm.verificationPage.code.hasFailure, isFalse);
      },
    );

    test(
      'weak password input notifies form and keeps failure until fixed',
      () {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        final password = loginForm.credentialsPage.password;
        password.input = 'short';
        expect(formNotifications, 1);
        expect(password.hasFailure, isTrue);

        password.input = 'longenough';
        expect(formNotifications, 2);
        expect(password.hasFailure, isFalse);
      },
    );

    test(
      'input should only be set on value after submit is called',
      () async {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        final password = loginForm.credentialsPage.password;
        password.input = 'valid_password';
        expect(formNotifications, 1);
        expect(password.hasValue, isFalse);

        await password.submit();
        expect(password.hasValue, isTrue);
        expect(password.value, password.input);
      },
    );

    test(
      'updates on one page still notify when another page was touched earlier',
      () {
        var formNotifications = 0;
        loginForm.observers.add(Observer(() => formNotifications++));

        loginForm.credentialsPage.email.input = 'a@gmail.com';
        loginForm.verificationPage.code.input = '9999';

        expect(formNotifications, 2);
      },
    );
  });

  group('generated form -', () {
    test('generated form exposes name and flattened items in page order', () {
      expect(loginForm.name, 'login-form');
      expect(loginForm.items, hasLength(3));
      expect(loginForm.items.map((e) => e.name).toList(), ['email', 'password', 'code']);
    });

    test('formContext getters reference the same InputData instances as pages', () {
      expect(identical(loginForm.credentialsPage.email, loginForm.pages[0].items[0]), isTrue);
      expect(identical(loginForm.credentialsPage.password, loginForm.pages[0].items[1]), isTrue);
      expect(identical(loginForm.verificationPage.code, loginForm.pages[1].items[0]), isTrue);
    });

    test('page submitResult data starts with no value', () {
      expect(loginForm.credentialsPage.submitResult.hasNoValue, isTrue);
      expect(loginForm.verificationPage.submitResult.hasNoValue, isTrue);
    });
  });

  group('submit -', () {
    test(
      'submitCredentialsPage runs page callback and sets automatically evaluates '
      'inputData items and tries to submit them first, then it will call onSubmitPage callback '
      'for the credentials page',
      () async {
        loginForm.credentialsPage.email.input = 'user@gmail.com';
        loginForm.credentialsPage.password.input = 'long_secret';

        await loginForm.submitCredentialsPage();

        expect(loginForm.credentialsPage.submitResult.value, isTrue);
        expect(loginForm.credentialsPage.email.value, 'user@gmail.com');
        expect(loginForm.credentialsPage.password.value, 'long_secret');
      },
    );

    test(
      'submitCredentialsPage calls onSubmitPage when inputs already have committed valid '
      'values and page submission should go through successfully',
      () async {
        loginForm.credentialsPage.email.input = 'user@gmail.com';
        loginForm.credentialsPage.password.input = 'long_secret';
        await loginForm.credentialsPage.email.submit();
        await loginForm.credentialsPage.password.submit();

        await loginForm.submitCredentialsPage();

        expect(loginForm.credentialsPage.submitResult.value, isTrue);
      },
    );

    test('submitVerificationPage completes async work and sets submitResult', () async {
      loginForm.verificationPage.code.input = '4242';

      await loginForm.submitVerificationPage();

      expect(loginForm.verificationPage.submitResult.value, isTrue);
      expect(loginForm.verificationPage.submitResult.hasNoOperation, isTrue);
      expect(loginForm.verificationPage.code.value, 4242);
    });

    test(
      'submitCredentialsPage sets failure when onSubmitPage leaves submitResult empty',
      () async {
        final form = createLoginForm(
          onSubmitCredentialsPage: (ctx, submitResult, email, password) async {},
        );
        form.credentialsPage.email.input = 'user@gmail.com';
        form.credentialsPage.password.input = 'long_secret';

        await form.submitCredentialsPage();

        expect(form.credentialsPage.submitResult.hasFailure, isTrue);
        expect(
          form.credentialsPage.submitResult.failure.message,
          contains('No value or failure was set on submitResult'),
        );
      },
    );

    test(
      'submitVerificationPage sets failure when onSubmitPage leaves submitResult empty',
      () async {
        final form = createLoginForm(
          onSubmitVerificationPage: (ctx, submitResult, code) async {},
        );
        form.verificationPage.code.input = '1000';

        await form.submitVerificationPage();

        expect(form.verificationPage.submitResult.hasFailure, isTrue);
        expect(
          form.verificationPage.submitResult.failure.message,
          contains('No value or failure was set on submitResult'),
        );
      },
    );
  });
}
