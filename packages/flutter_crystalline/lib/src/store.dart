import 'package:crystalline/crystalline.dart';
import 'package:flutter/widgets.dart';

abstract class Store extends Data<void> with ChangeNotifier {
  // ignore: unused_field
  late final ListData<Object?> _statesList = ListData(states);

  List<Data<Object?>> get states;

  @override
  String? get name => storeName;

  String get storeName;

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
