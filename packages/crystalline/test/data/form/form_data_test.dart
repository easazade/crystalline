import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../../test_utils/test_logger.dart';

part 'form_data_test.crystalline.dart';

@FormClass(
  name: 'login-form',
  pages: [
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
  ],
)
class _LoginForm {}

LoginForm createLoginForm({
  Future<void> Function(
    LoginFormContext formContext,
    Data<bool> submitResult,
    CredentialsPageSubmitValueArgs args,
  )? onSubmitCredentialsPage,
  Future<void> Function(
    LoginFormContext formContext,
    Data<bool> submitResult,
    VerificationPageSubmitValueArgs args,
  )? onSubmitVerificationPage,
  String? emailHint,
  String? emailInitialValue,
  Operation? emailOperation,
  Failure? emailFailure,
  List<dynamic>? emailSideEffects,
  bool emailIsOptional = false,
}) {
  return LoginForm(
    credentialsPage: CredentialsPage(
      emailInputData: EmailInputData(
        isOptional: emailIsOptional,
        hint: emailHint,
        initialValue: emailInitialValue,
        operation: emailOperation,
        failure: emailFailure,
        sideEffects: emailSideEffects,
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
      onSubmitPage: onSubmitCredentialsPage ??
          (formContext, submitResult, args) async {
            submitResult.value = true;
          },
    ),
    verificationPage: VerificationPage(
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
      onSubmitPage: onSubmitVerificationPage ??
          (formContext, submitResult, args) async {
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
          onSubmitCredentialsPage: (ctx, submitResult, args) async {},
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

  group('clearAllFailures / clearAllOperations -', () {
    test('clearAllFailures removes failure from every InputData item', () {
      loginForm.credentialsPage.email.input = 'not-gmail';
      loginForm.credentialsPage.password.input = 'short';
      loginForm.verificationPage.code.input = 'ab';

      expect(loginForm.credentialsPage.email.hasFailure, isTrue);
      expect(loginForm.credentialsPage.password.hasFailure, isTrue);
      expect(loginForm.verificationPage.code.hasFailure, isTrue);

      loginForm.clearAllFailures();

      expect(loginForm.credentialsPage.email.hasFailure, isFalse);
      expect(loginForm.credentialsPage.password.hasFailure, isFalse);
      expect(loginForm.verificationPage.code.hasFailure, isFalse);
    });

    test('clearAllOperations removes operation from every InputData item', () {
      loginForm.credentialsPage.email.operation = Operation.read;
      loginForm.credentialsPage.password.operation = Operation.update;
      loginForm.verificationPage.code.operation = Operation('pending');

      expect(loginForm.credentialsPage.email.hasAnyOperation, isTrue);
      expect(loginForm.credentialsPage.password.hasAnyOperation, isTrue);
      expect(loginForm.verificationPage.code.hasAnyOperation, isTrue);

      loginForm.clearAllOperations();

      expect(loginForm.credentialsPage.email.hasNoOperation, isTrue);
      expect(loginForm.credentialsPage.password.hasNoOperation, isTrue);
      expect(loginForm.verificationPage.code.hasNoOperation, isTrue);
    });

    test('clearAllFailures does not clear operations on input items', () {
      loginForm.credentialsPage.email.input = 'bad';
      loginForm.credentialsPage.email.operation = Operation.read;

      loginForm.clearAllFailures();

      expect(loginForm.credentialsPage.email.hasFailure, isFalse);
      expect(loginForm.credentialsPage.email.operationOrNull, Operation.read);
    });

    test('clearAllOperations does not clear failures on input items', () {
      loginForm.credentialsPage.password.input = 'short';
      loginForm.credentialsPage.password.operation = Operation.update;

      loginForm.clearAllOperations();

      expect(loginForm.credentialsPage.password.hasFailure, isTrue);
      expect(loginForm.credentialsPage.password.hasNoOperation, isTrue);
    });
  });

  group('EmailInputData constructor args -> InputData -', () {
    test('hint from EmailInputData is applied and updates notify form and item', () {
      final form = createLoginForm(emailHint: 'Your email address');
      final email = form.credentialsPage.email;

      expect(email.hint, 'Your email address');

      var formNotifications = 0;
      var itemNotifications = 0;
      form.observers.add(Observer(() => formNotifications++));
      email.observers.add(Observer(() => itemNotifications++));

      email.hint = 'Updated hint';

      expect(formNotifications, 1);
      expect(itemNotifications, 1);
      expect(email.hint, 'Updated hint');
    });

    test('initialValue from EmailInputData sets value and value changes notify form and item', () {
      final form = createLoginForm(emailInitialValue: 'prefilled@gmail.com');
      final email = form.credentialsPage.email;

      expect(email.hasValue, isTrue);
      expect(email.value, 'prefilled@gmail.com');

      var formNotifications = 0;
      var itemNotifications = 0;
      form.observers.add(Observer(() => formNotifications++));
      email.observers.add(Observer(() => itemNotifications++));

      email.value = 'other@gmail.com';

      expect(formNotifications, 1);
      expect(itemNotifications, 1);
      expect(email.value, 'other@gmail.com');
    });

    test('operation from EmailInputData is applied and clearing it notifies form and item', () {
      final form = createLoginForm(emailOperation: Operation.read);
      final email = form.credentialsPage.email;

      expect(email.isReading, isTrue);

      var formNotifications = 0;
      var itemNotifications = 0;
      form.observers.add(Observer(() => formNotifications++));
      email.observers.add(Observer(() => itemNotifications++));

      email.operation = null;

      expect(formNotifications, 1);
      expect(itemNotifications, 1);
      expect(email.hasNoOperation, isTrue);
    });

    test('failure from EmailInputData is applied and clearing it notifies form and item', () {
      final form = createLoginForm(emailFailure: Failure('initial failure'));
      final email = form.credentialsPage.email;

      expect(email.hasFailure, isTrue);
      expect(email.failure.message, 'initial failure');

      var formNotifications = 0;
      var itemNotifications = 0;
      form.observers.add(Observer(() => formNotifications++));
      email.observers.add(Observer(() => itemNotifications++));

      email.failure = null;

      expect(formNotifications, 1);
      expect(itemNotifications, 1);
      expect(email.hasFailure, isFalse);
    });

    test('sideEffects from EmailInputData are applied and adding more notifies form and item', () {
      final form = createLoginForm(emailSideEffects: ['seed']);
      final email = form.credentialsPage.email;

      expect(email.sideEffects.all, contains('seed'));

      var formNotifications = 0;
      var itemNotifications = 0;
      form.observers.add(Observer(() => formNotifications++));
      email.observers.add(Observer(() => itemNotifications++));

      email.sideEffects.add('extra');

      expect(formNotifications, 1);
      expect(itemNotifications, 1);
      expect(email.sideEffects.all, containsAll(['seed', 'extra']));
    });

    test('isOptional from EmailInputData is applied and toggling notifies form and item', () {
      final form = createLoginForm(emailIsOptional: true);
      final email = form.credentialsPage.email;

      expect(email.isOptional, isTrue);

      var formNotifications = 0;
      var itemNotifications = 0;
      form.observers.add(Observer(() => formNotifications++));
      email.observers.add(Observer(() => itemNotifications++));

      email.isOptional = false;

      expect(formNotifications, 1);
      expect(itemNotifications, 1);
      expect(email.isOptional, isFalse);
    });
  });
}
