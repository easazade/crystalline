import 'package:flutter_crystalline/flutter_crystalline.dart';

class StoreLogger {
  final Store store;
  StoreLogger(this.store);

  void info(String message, {String? tag}) {
    CrystallineGlobalConfig.logger.log('${_prefix(logLevel: 'info', tag: tag)} $message');
  }

  void debug(String message, {String? tag}) {
    CrystallineGlobalConfig.logger.log('${_prefix(logLevel: 'debug', tag: tag)} $message');
  }

  String _prefix({required String logLevel, String? tag}) {
    var prefix = '${store.name}-$logLevel:';
    if (tag != null) {
      prefix = '[$tag]-$prefix';
    }
    return prefix;
  }
}
