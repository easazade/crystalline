import 'package:collection/collection.dart';
import 'package:crystalline/src/config/global_config.dart';
import 'package:crystalline/src/data_types/collection_data.dart';
import 'package:crystalline/src/data_types/data.dart';
import 'package:crystalline/src/data_types/failure.dart';
import 'package:crystalline/src/exceptions.dart';
import 'package:meta/meta.dart';

part 'form_page_data.dart';
part 'input_data.dart';
part 'input_validation.dart';

typedef FormData = ListData<FormPageData>;
