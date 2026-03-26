import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies listeners whenever [stream] emits. Subscribes on the first
/// [Listenable.addListener] and cancels when the last listener is removed.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<dynamic> stream) : _stream = stream;

  final Stream<dynamic> _stream;
  StreamSubscription<dynamic>? _subscription;

  @override
  void addListener(VoidCallback listener) {
    final hadListeners = hasListeners;
    super.addListener(listener);
    if (!hadListeners) {
      _subscription = _stream.listen((_) => notifyListeners());
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _subscription?.cancel();
      _subscription = null;
    }
  }
}

/// Bridges a [Stream] to Flutter's [Listenable] so widgets like [AnimatedBuilder]
/// can rebuild when the stream emits.
///
/// The first [Listenable.addListener] subscribes to the stream; the subscription
/// is canceled when the last listener is removed. For a single-subscription
/// stream, only one active [asListenable] bridge should listen at a time.
extension StreamListenableExtension<T> on Stream<T> {
  /// Returns a [Listenable] that calls [ChangeNotifier.notifyListeners] whenever
  /// this stream emits a value.
  Listenable asListenable() => StreamListenable(this);
}
