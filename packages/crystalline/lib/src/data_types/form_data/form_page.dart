
part of 'form_data.dart';

class FormPage {
  FormPage({
    required this.name,
    required this.items,
  });

  final String name;
  final List<InputData> items;

  @override
  bool operator ==(Object other) {
    if (other is! FormPage) return false;
    return name == other.name &&
        ListEquality<InputData>().equals(items, other.items);
  }

  @override
  int get hashCode => Object.hash(
        name,
        ListEquality<InputData>().hash(items),
      );
}
