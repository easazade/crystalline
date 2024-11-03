import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class Store extends CollectionData<Object?> with ChangeNotifier {
  @override
  List<Data<Object?>> get items => states;

  List<Data<Object?>> get states;

  void publish() {
    notifyListeners();
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(
        '${this.runtimeType}: ${CrystallineGlobalConfig.logger.generateToStringForData(this)}');

    if (states.isNotEmpty) {
      buffer.writeln();
    }

    for (final state in states) {
      buffer.writeln(state.toString());
    }

    return buffer.toString();
  }
}
