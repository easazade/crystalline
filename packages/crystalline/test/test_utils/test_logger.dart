import 'package:crystalline/src/config/logger/default_crystalline_logger.dart';

class CrystallineTestLogger extends DefaultCrystallineLogger {
  @override
  void log(object) {
    print(object);
  }
}
