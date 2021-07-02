import 'package:collection/collection.dart';

final apiUtils = ApiUtils();

class ApiUtils {
  T? enumFrom<T extends Object>(String? value, List<T> enums) {
    return enums.firstWhereOrNull((e) => enumName(e) == value);
  }

  String? enumName(Object? value) {
    if (value == null) return null;
    return value.toString().split('.').last;
  }
}
