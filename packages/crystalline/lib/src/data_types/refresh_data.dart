part of 'data.dart';

class RefreshData<T> extends Data<T> {
  RefreshData({
    required Future<RefreshStatus> Function(RefreshData<T> currentData) refresh,
    super.value,
    super.failure,
    super.operation,
    List<dynamic>? super.sideEffects,
    super.name,
    this.retryDelay = const Duration(milliseconds: 1000),
    this.maxRetry = 1,
  }) : _refreshCallback = refresh;

  final Future<RefreshStatus> Function(RefreshData<T> currentData) _refreshCallback;
  final Duration retryDelay;
  final int maxRetry;
  RefreshStatus _status = RefreshStatus.failed;

  Completer<void>? _refreshCompleter;
  var _disposed = false;

  Future<void> refresh({bool allowRetry = true}) async {
    if (_disposed) {
      return;
    }

    Future<RefreshStatus> tryRefreshCallback() async {
      RefreshStatus status;

      try {
        status = await _refreshCallback(this);
      } catch (e, stack) {
        status = RefreshStatus.failed;
        print(e);
        print(stack);
      }

      return status;
    }

    final isRefreshing = _refreshCompleter != null && !_refreshCompleter!.isCompleted;

    if (_value == null && !isRefreshing) {
      _refreshCompleter = Completer();

      _log(CrystallineGlobalConfig.logger.greenText('Refreshing ${name ?? "RefreshData<$T>"}'));
      _status = await tryRefreshCallback();

      if (_status == RefreshStatus.failed) {
        _log(
          CrystallineGlobalConfig.logger.redText(
            '❌ Refresh failed for ${name ?? "RefreshData<$T>"} retrying after $retryDelay | failure: $failureOrNull',
          ),
        );

        var retryCount = 1;
        while (retryCount <= maxRetry && _status == RefreshStatus.failed) {
          _log(CrystallineGlobalConfig.logger.yellowText('Retry attempt $retryCount'));
          _status = await tryRefreshCallback();
          _log(CrystallineGlobalConfig.logger.yellowText('Retry attempt result: status: $_status | data: $this'));
          retryCount += 1;
        }
        if (_status == RefreshStatus.done) {
          _log(
            CrystallineGlobalConfig.logger.greenText(
              '✅ Refreshed on Retry attempt $retryCount ${name ?? "RefreshData<$T>"} | status: $_status | operation: $operation | value: $valueOrNull',
            ),
          );
        } else {
          _log(
            CrystallineGlobalConfig.logger.redText(
              '❌ All refresh retry attempts failed for ${name ?? "RefreshData<$T>"} | failure: $failureOrNull',
            ),
          );
        }
      } else {
        _log(
          CrystallineGlobalConfig.logger.greenText(
            '✅ Refreshed ${name ?? "RefreshData<$T>"} | status: $_status | operation: $operation | value: $valueOrNull',
          ),
        );

        if (operation != Operation.none) {
          _log(
            CrystallineGlobalConfig.logger.orangeText(
              '⚠️ Operation after successful refresh was not set to Operation.none. '
              'Usually it is desired to set the Operation to Operation.none when there is no operation is going on anymore. '
              'Please implement refresh callback for RefreshData object to do so.',
            ),
          );
        }
      }

      _refreshCompleter?.complete();
    }

    return _refreshCompleter?.future;
  }

  void _log(String msg) {
    CrystallineGlobalConfig.logger.log(msg);
  }

  Future<void> ensureRefreshComplete() => _refreshCompleter?.future ?? Future.value();

  RefreshStatus get status => _status;

  @override
  void addEventListener(bool Function(Event event) listener) {
    if (_value == null) refresh(allowRetry: false);
    super.addEventListener(listener);
  }

  @override
  void addObserver(void Function() observer) {
    if (_value == null) refresh(allowRetry: false);
    super.addObserver(observer);
  }

  @override
  String toString() => CrystallineGlobalConfig.logger.generateToStringForData(this);

  void dispose() {
    _disposed = true;
    _observers.clear();
    _eventListeners.clear();
    reset();
  }
}

enum RefreshStatus { done, failed }
