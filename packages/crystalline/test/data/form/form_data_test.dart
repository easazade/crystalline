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
  ),
  FormPageInfo(
    name: 'verification',
    items: [
      InputDataInfo(name: 'code', inputType: String, valueType: int),
    ],
  ),
])
class _LoginForm {}


// constructor(
//     emailPage=  EmailPage(
//       emailInput: EmailInput(
//         validate: (){}
//         submit: (){}
//       ),
//       passwordInput: EmailInput(
//         validate: (){}
//         submit: (){}
//       ),
//       onSubmitPage: (){},
//     ),
//     verifyPage = VerifyPage(
//       verificationCodeInput: VerificationCodeInput(
//         validate: (){}
//         submit: (){}
//       ),
//       onSubmitPage: (){},
//     ),
//     onSubmitForm : (){},
// )

void main() {
  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  group('items', () {
    test('form data should be updated when InputData items get updated', () {});
  });
}
