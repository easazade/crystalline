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
])
class _LoginForm {}

void main() {
  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  group('items', () {
    test('form data should be updated when InputData items get updated', () {});
  });
}
