import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/collection_data.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:crystalline/src/semantics/operation.dart';
import 'package:meta/meta.dart';

part 'input_data.dart';
part 'input_validation.dart';

class FormData extends CollectionData<dynamic, InputData> {
  FormData(
    List<InputData> items, {
    Operation? operation,
    Failure? failure,
    List<dynamic>? sideEffects,
  }) : _pages = [items] {
    this.operation = operation;
    this.failure = failure;
    if (sideEffects != null) {
      this.sideEffects.addAll(sideEffects);
    }
  }

  FormData.pages(
    List<List<InputData>> pages, {
    Operation? operation,
    Failure? failure,
    List<dynamic>? sideEffects,
  }) : _pages = pages {
    this.operation = operation;
    this.failure = failure;
    if (sideEffects != null) {
      this.sideEffects.addAll(sideEffects);
    }
  }

  final List<List<InputData>> _pages;

  @override
  List<InputData> get items => _pages.flattened.toList();

  @override
  Iterator<InputData> get iterator => items.iterator;

  @override
  InputData operator [](int index) => items[index];

  // Required by Data.updateFrom @mustBeOverridden; delegates to CollectionData.
  @override
  // ignore: unnecessary_overrides
  void updateFrom(Data<List<InputData>> data) {
    super.updateFrom(data);
  }

  @override
  FormData copy() => FormData(
        items.map((data) => data.copy()).toList(),
        operation: operationOrNull,
        failure: failureOrNull,
        sideEffects: sideEffects.all.toList(),
      );

  @override
  bool operator ==(Object other) {
    if (other is! FormData) return false;

    return runtimeType == other.runtimeType &&
        ListEquality<InputData>().equals(items, other.items) &&
        operationOrNull == other.operationOrNull &&
        sideEffects == other.sideEffects &&
        failureOrNull == other.failureOrNull;
  }

  @override
  int get hashCode => Object.hashAll([
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
