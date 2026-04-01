import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/collection_data.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:crystalline/src/semantics/operation.dart';
import 'package:meta/meta.dart';

part 'form_page.dart';
part 'input_data.dart';
part 'input_validation.dart';

abstract class FormData extends CollectionData<dynamic, InputData<dynamic, dynamic>> {
  FormData({
    Operation? operation,
    Failure? failure,
    List<dynamic>? sideEffects,
  }) {
    this.operation = operation;
    this.failure = failure;
    if (sideEffects != null) {
      this.sideEffects.addAll(sideEffects);
    }
  }

  List<FormPage> get pages;

  void clearAllFailures() {
    for (var inputData in items) {
      inputData.failure = null;
    }
  }

  void clearAllOperations() {
    for (var inputData in items) {
      inputData.operation = null;
    }
  }

  @override
  String get name;

  @override
  List<InputData> get items => pages.map((page) => page.items).flattened.toList();

  @override
  Iterator<InputData> get iterator => items.iterator;

  @override
  InputData operator [](int index) => items[index];

  /// submits the current state of [InputData] items. If all items will result in a value it will
  // TODO: the FormData should be auto generated. The submit method should be auto generated.
  // so does the onSubmit callback argument. the onSubmit needs to have the value type of all the input-data items
  // when submission for all items is successful then onSubmit callback of the generated FormData should
  // be called with those values in the generated submit method.
  //
  // Each page must have a result value after submitted just like the value that InputData. Each page needs to be
  // submitted. so each page must have a onSubmit callback and possibly submit method
  // I think each page should have a name and a status whether that page is submitted or not. I should possibly
  // build a FormPage as well.
  // Forget the list always use pages
  //
  // Then generate one form and write some tests for it.
  Future<void> submit();

  // @override
  // FormData copy() => FormData(
  //       pages: pages,
  //       operation: operationOrNull,
  //       failure: failureOrNull,
  //       sideEffects: sideEffects.all.toList(),
  //       name: name,
  //     );

  @override
  bool operator ==(Object other) {
    if (other is! FormData) return false;

    return runtimeType == other.runtimeType &&
        pages == other.pages &&
        ListEquality<InputData>().equals(items, other.items) &&
        operationOrNull == other.operationOrNull &&
        sideEffects == other.sideEffects &&
        failureOrNull == other.failureOrNull;
  }

  @override
  int get hashCode => Object.hashAll([
        pages,
        runtimeType,
        items,
        operationOrNull,
        failureOrNull,
        sideEffects.all,
      ]);

  @override
  Stream<FormData> get stream => streamController.stream.map((e) => this);

  @override
  void modify(void Function(FormData data) fn) {
    super.modify((data) => fn(data as FormData));
  }

  @override
  Future<void> modifyAsync(Future<void> Function(FormData data) fn) {
    return super.modifyAsync((data) => fn(data as FormData));
  }

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);
}
