import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class Store extends Data<void> with ChangeNotifier {
  List<Data<Object?>> get states;

  @override
  String? get name;

  void publish() => (this as ChangeNotifier).notifyListeners();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('$runtimeType: ${CrystallineGlobalConfig.logger.generateToStringForData(this)}');

    if (states.isNotEmpty) {
      buffer.writeln();
    }

    for (final state in states) {
      buffer.writeln(state.toString());
    }

    return buffer.toString();
  }
}
