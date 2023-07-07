import 'package:crystalline/crystalline.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late Data<String> data;
  late DataTestObserver<String, Data<String>> testObserver;

  setUp(() {
    data = Data();
    testObserver = DataTestObserver(data);
  });


}
