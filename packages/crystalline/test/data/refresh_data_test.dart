import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../test_utils/test_logger.dart';

void main() {
  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  // test(
  //   'Should not refresh data if refresh action is not triggered',
  //   () async {
  //     final refreshData = RefreshData<int>(
  //       refresh: (data) async {
  //         data.operation = Operation.read;
  //         await Future<void>.delayed(const Duration(milliseconds: 100));
  //         data.value = 20;
  //         data.operation = Operation.none;
  //         return RefreshStatus.done;
  //       },
  //     );

  //     await refreshData.ensureRefreshComplete();

  //     expect(refreshData.valueOrNull, isNull);
  //   },
  // );

  // test(
  //   'Should refresh data if refresh action is triggered by hasValue',
  //   () async {
  //     final refreshData = RefreshData<int>(
  //       refresh: (data) async {
  //         data.operation = Operation.read;
  //         await Future<void>.delayed(const Duration(milliseconds: 100));
  //         data.value = 20;
  //         data.operation = Operation.none;
  //         return RefreshStatus.done;
  //       },
  //     );

  //     // when
  //     refreshData.hasValue;
  //     await refreshData.ensureRefreshComplete();

  //     // then
  //     expect(refreshData.valueOrNull, isNotNull);
  //     expect(refreshData.value, equals(20));
  //   },
  // );

  // test(
  //   'Should refresh data if retry refreshing action if first refresh try is failed',
  //   () async {
  //     int attempt = 1;

  //     final refreshData = RefreshData<int>(
  //       refresh: (data) async {
  //         data.operation = Operation.read;
  //         await Future<void>.delayed(const Duration(milliseconds: 100));
  //         if (attempt == 1) {
  //           attempt += 1;
  //           data.operation = Operation.none;
  //           return RefreshStatus.failed;
  //         } else {
  //           data.value = 20;
  //           data.operation = Operation.none;
  //           return RefreshStatus.done;
  //         }
  //       },
  //     );

  //     // when
  //     refreshData.hasValue;
  //     await refreshData.ensureRefreshComplete();

  //     // then
  //     expect(refreshData.valueOrNull, isNotNull);
  //     expect(refreshData.value, equals(20));
  //   },
  // );

  // test(
  //   'Should not trigger refresh implicitly if already has a value',
  //   () async {
  //     int attempt = 1;

  //     final refreshData = RefreshData<int>(
  //       refresh: (data) async {
  //         data.operation = Operation.read;
  //         await Future<void>.delayed(const Duration(milliseconds: 100));
  //         if (attempt == 1) {
  //           data.value = 10;
  //           data.operation = Operation.none;
  //         } else {
  //           data.value = 20;
  //           data.operation = Operation.none;
  //         }
  //         attempt += 1;
  //         return RefreshStatus.done;
  //       },
  //     );

  //     // when
  //     refreshData.hasValue;
  //     await refreshData.ensureRefreshComplete();

  //     // then
  //     expect(refreshData.valueOrNull, isNotNull);
  //     expect(refreshData.value, equals(10));

  //     // try implicit retrigger
  //     refreshData.hasValue;
  //     await refreshData.ensureRefreshComplete();

  //     // should not refresh since there is already a value and there is no need to refresh
  //     expect(refreshData.valueOrNull, isNotNull);
  //     expect(refreshData.value, equals(10));
  //   },
  // );

  // test(
  //   'Should refresh again  even if data has value when refresh method is called on it',
  //   () async {
  //     int attempt = 1;

  //     final refreshData = RefreshData<int>(
  //       refresh: (data) async {
  //         data.operation = Operation.read;
  //         await Future<void>.delayed(const Duration(milliseconds: 100));
  //         if (attempt == 1) {
  //           data.value = 10;
  //           data.operation = Operation.none;
  //         } else {
  //           data.value = 20;
  //           data.operation = Operation.none;
  //         }
  //         attempt += 1;
  //         return RefreshStatus.done;
  //       },
  //     );

  //     // when
  //     refreshData.hasValue;
  //     await refreshData.ensureRefreshComplete();

  //     // then
  //     expect(refreshData.valueOrNull, isNotNull);
  //     expect(refreshData.value, equals(10));

  //     // calling refresh method to refresh the data again
  //     refreshData.refresh();
  //     await refreshData.ensureRefreshComplete();

  //     // should refresh
  //     expect(refreshData.valueOrNull, isNotNull);
  //     expect(refreshData.value, equals(20));
  //   },
  // );

  // test(
  //   'All refresh retry attempts should fail',
  //   () async {
  //     final refreshData = RefreshData<int>(
  //       name: 'ageData',
  //       refresh: (data) async {
  //         data.operation = Operation.read;
  //         await Future<void>.delayed(const Duration(milliseconds: 100));
  //         data.operation = Operation.none;
  //         return RefreshStatus.failed;
  //       },
  //     );

  //     // when
  //     refreshData.hasValue;
  //     refreshData.hasValue;
  //     refreshData.hasValue;
  //     await refreshData.ensureRefreshComplete();

  //     // then
  //     expect(refreshData.valueOrNull, isNull);
  //   },
  // );
}
