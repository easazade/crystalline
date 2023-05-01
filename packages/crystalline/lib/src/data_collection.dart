import 'package:crystalline/src/data.dart';

abstract class CollectionData extends Data<List<Data<Object?>>> {
  List<Data<Object?>> get items;

  List<Data<Object?>>? get requiredItems => null;

  @override
  List<Data<Object?>> get value => items;

  @override
  bool get isAvailable {
    if (requiredItems != null && requiredItems!.isNotEmpty) {
      return requiredItems!.where((data) => data.isNotAvailable).isEmpty;
    }

    return true;
  }

  @override
  bool get isLoading {
    if (requiredItems != null && requiredItems!.isNotEmpty) {
      final isIt = requiredItems!
          .where((data) => data.isLoading && data.isNotAvailable)
          .isNotEmpty;

      return isIt;
    }

    return super.isLoading;
  }
}
