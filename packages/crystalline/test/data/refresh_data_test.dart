import 'dart:async';

import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../test_utils/test_logger.dart';

void main() {
  setUpAll(() {
    CrystallineGlobalConfig.logger = CrystallineTestLogger();
  });

  group('RefreshData', () {
    test('Should create RefreshData with initial state', () {
      final refreshData = RefreshData<String>(
        refresh: (_) async => RefreshStatus.done,
        value: 'initial',
      );

      expect(refreshData.valueOrNull, 'initial');
      expect(refreshData.status, RefreshStatus.failed);
    });

    test('Should refresh and update value when callback returns done', () async {
      final refreshData = RefreshData<String>(
        refresh: (data) async {
          data.value = 'refreshed';
          data.operation = Operation.none;
          return RefreshStatus.done;
        },
      );

      await refreshData.refresh();

      expect(refreshData.valueOrNull, 'refreshed');
      expect(refreshData.status, RefreshStatus.done);
    });

    test('Should set status to failed when callback throws', () async {
      final refreshData = RefreshData<String>(
        refresh: (_) async {
          throw Exception('refresh error');
        },
      );

      await refreshData.refresh();

      expect(refreshData.status, RefreshStatus.failed);
    });

    test('Should retry when refresh fails and maxRetry > 0', () async {
      var attemptCount = 0;
      final refreshData = RefreshData<String>(
        refresh: (_) async {
          attemptCount++;
          if (attemptCount < 2) {
            return RefreshStatus.failed;
          }
          return RefreshStatus.done;
        },
        maxRetry: 2,
        retryDelay: Duration.zero,
      );

      await refreshData.refresh();

      expect(attemptCount, 2);
      expect(refreshData.status, RefreshStatus.done);
    });

    test('ensureRefreshComplete should return future when refresh is in progress', () async {
      final completer = Completer<RefreshStatus>();
      final refreshData = RefreshData<String>(
        refresh: (_) async => completer.future,
      );

      final refreshFuture = refreshData.refresh();
      final ensureFuture = refreshData.ensureRefreshComplete();

      completer.complete(RefreshStatus.done);
      await refreshFuture;
      await ensureFuture;

      expect(refreshData.status, RefreshStatus.done);
    });

    test('should try refresh data when observer added', () async {
      // TODO
    });

    test(
      'should not refresh when data already has value and a new observer is added',
      () async {
        // TODO
      },
    );
  });
}
