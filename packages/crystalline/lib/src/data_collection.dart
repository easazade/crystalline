import 'package:crystalline/src/data.dart';

abstract class DataCollection extends Data<List<Data<Object?>>> {
  List<Data<Object?>> get items;

  List<Data<Object?>>? get requiredItems => null;

  @override
  List<Data<Object?>> get value => items;

  @override
  bool get isAvailable {
    if (requiredItems != null && requiredItems!.isNotEmpty) {
      return requiredItems!.where((data) => data.isNotAvailable).isEmpty;
    } else {
      return items.where((data) => data.isNotAvailable).isEmpty;
    }
  }

  @override
  bool get isLoading {
    if (requiredItems != null && requiredItems!.isNotEmpty) {
      return requiredItems!.where((data) => data.isLoading).isNotEmpty;
    }

    return super.isLoading;
  }
}
