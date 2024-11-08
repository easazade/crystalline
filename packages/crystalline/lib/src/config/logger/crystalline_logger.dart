import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';

abstract class CrystallineLogger {
  String redText(dynamic object);


  String greenText(dynamic object);

  String yellowText(dynamic object);

  String orangeText(dynamic object);

  String magentaText(dynamic object);

  String cyanText(dynamic object);

  String whiteText(dynamic object);

  String whiteTextRedBg(dynamic object);

  String whiteTextBlueBg(dynamic object);

  String resetTextColors(dynamic object);

  String ellipsize(String text, {required int maxSize});

  String generateToStringForData<T>(Data<T> data);

  String generateToStringForFailure(Failure failure);

  String? globalLogFilter(Data<dynamic> data);

  void log(dynamic object);
}
