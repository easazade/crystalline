// TODO: delete this file afterwards

abstract interface class modifiable<T> {
  set value(T value);
}

abstract interface class observable<T> {
  T get value;
}

class base_data<T> {
  T? _value;
}

mixin modifiable_data<T> on base_data<T> implements modifiable<T> {
  @override
  set value(T value) => _value = value;
}

mixin observable_data<T> on base_data<T> implements observable<T> {
  @override
  T get value => _value!;
}

class data<T> extends base_data<T> with modifiable_data<T>, observable_data<T> {}

void sss() {
  final d = data<String>();
  d.value = 'Something';
  print(d.value);
}
