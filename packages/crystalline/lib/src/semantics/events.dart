class Events {
  bool _allowedToNotify = true;

  final List<bool Function(Event event)> _listeners = [];

  // returns a copy of current listeners added.
  List<bool Function(Event event)> get listeners => _listeners.toList();

  bool get hasListeners => _listeners.isNotEmpty;

  void addListener(bool Function(Event event) listener) {
    _listeners.add(listener);
  }

  void removeListener(bool Function(Event event) listener) {
    _listeners.remove(listener);
  }

  void dispatch(Event event) {
    if (_allowedToNotify) {
      for (final callback in _listeners) {
        final isEventConsumed = callback(event);
        if (isEventConsumed) {
          break;
        }
      }
    }
  }

  void allowNotify() => _allowedToNotify = true;

  void disallowNotify() => _allowedToNotify = false;
}

class Event {
  const Event(this.name);

  final String name;

  @override
  bool operator ==(Object other) {
    if (other is! Event) return false;
    return other.runtimeType == runtimeType && name == other.name;
  }

  @override
  int get hashCode => name.hashCode + 12;

  @override
  String toString() => name;
}
