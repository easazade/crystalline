import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../../test_utils/test_logger.dart';

void main() {
  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  group('items', () {
    test('form data should be updated when InputData items get updated', () {
      final formData = FormData([]);
    });
  });
}
