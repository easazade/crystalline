import 'dart:math';

final _random = Random();

extension ListExt<T> on Iterable<T> {
  T randomItem({List<T> exceptionValues = const []}) {
    if (length == 0) throw Exception('Cannot return a random vlaue from empty list');
    var value = elementAt(_random.nextInt(length));
    if (value != null && exceptionValues.contains(value)) {
      value = randomItem(exceptionValues: exceptionValues);
    }
    return value;
  }
}
