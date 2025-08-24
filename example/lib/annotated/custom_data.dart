import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'custom_data.crystalline.dart';

class COperation extends Operation {
  COperation(super.name);

  
}

@data(customOperations: ['DeleteUser', 'UpdateProfile'])
class CustomData extends Data<String> with _CustomData {
  @override
  COperation get operation {
    return COperation('name');
  }
}
