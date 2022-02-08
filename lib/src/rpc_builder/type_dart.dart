import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart' hide DynamicType;
import '../utils/type.dart';
import 'utils.dart';

ValueType typeFromDart(DartType type) {
  var isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
  if (type.isDartCoreList) {
    ValueType itemType = ObjectType(isNullable: true);
    if (type is ParameterizedType) {
      itemType = typeFromDart(type.typeArguments.first);
    }
    return ListType(itemType, isNullable: isNullable);
  } else if (type.isDartCoreMap) {
    ValueType keyType = ObjectType(isNullable: true);
    ValueType valueType = ObjectType(isNullable: true);
    if (type is ParameterizedType) {
      keyType = typeFromDart(type.typeArguments[0]);
      valueType = typeFromDart(type.typeArguments[1]);
    }
    return MapType(keyType, valueType, isNullable: isNullable);
  } else if (type.isDartCoreInt) {
    return IntType(isNullable: isNullable);
  } else if (type.isDartCoreDouble) {
    return DoubleType(isNullable: isNullable);
  } else if (type.isDartCoreNum) {
    return NumType(isNullable: isNullable);
  } else if (type.isDartCoreBool) {
    return BoolType(isNullable: isNullable);
  } else if (type.isDartCoreString) {
    return StringType(isNullable: isNullable);
  } else if (isDateTime(type)) {
    return DateTimeType(isNullable: isNullable);
  } else if (type.isDartCoreObject) {
    return ObjectType(isNullable: isNullable);
  } else if (type.isDynamic) {
    return DynamicType();
  } else {
    var element = type.element;
    if (element is ClassElement) {
      if (element.isEnum) {
        return EnumType(element.name, isNullable: isNullable);
      }
      var genericTypes = <String, ValueType>{};
      if (type is ParameterizedType) {
        var i = 0;
        for (var typeArgument in type.typeArguments) {
          genericTypes[element.typeParameters[i].name] =
              typeFromDart(typeArgument);
          ++i;
        }
      }
      return ComplexType(element.name,
          isNullable: isNullable, genericTypes: genericTypes);
    }
  }
  throw Exception('Unrecognized type $type');
}
