import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';

abstract class CrystallineLogger {
  String inRed(dynamic object);

  String inGreen(dynamic object);

  String inYellow(dynamic object);

  String inOrange(dynamic object);

  String inMagenta(dynamic object);

  String inCyan(dynamic object);

  String inWhite(dynamic object);

  String inReset(dynamic object);

  String inBlinking(dynamic object);

  String inBlinkingFast(dynamic object);

  String ellipsize(String text, {required int maxSize});

  String generateToStringForData<T>(Data<T> data);

  String generateToStringForFailure(Failure failure);
}
