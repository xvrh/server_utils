import 'package:collection/collection.dart';
import '../utils/string.dart';

class Value {
  final String accessor;
  final ValueType type;

  Value(this.accessor, this.type);

  String toJsonCode() => type.toJsonCode(accessor);

  String fromJsonCode(ValueType newType) => newType.fromJsonCode(this);

  Value get asNonNull => Value(accessor, type.copyWith(isNullable: false));
}

abstract class ValueType {
  final bool isNullable;

  ValueType({required this.isNullable});

  String get questionMark => isNullable ? '?' : '';
  String questionIfNeeded(ValueType target) =>
      target.isNullable && isNullable ? '?' : '';
  String bangIfNeeded(ValueType target) =>
      target.isNullable && !isNullable ? '!' : '';
  String castToThisFrom(ValueType target) =>
      '$nameWithoutNullability${questionIfNeeded(target)}';
  String access(Value value) => '${value.accessor}${bangIfNeeded(value.type)}';

  ValueType copyWith({bool? isNullable});

  String toJsonCode(String target);

  String fromJsonCode(Value value);

  bool equalsWithoutNullability(other);

  String get nameWithoutNullability;

  String get name => '$nameWithoutNullability$questionMark';

  @override
  int get hashCode => nameWithoutNullability.hashCode ^ isNullable.hashCode;

  @override
  bool operator ==(other) {
    if (other is! ValueType) return false;
    return equalsWithoutNullability(other) && isNullable == other.isNullable;
  }

  @override
  String toString() => 'Type($name)';
}

class ObjectType extends ValueType {
  ObjectType({bool isNullable = false}) : super(isNullable: isNullable);

  @override
  String toJsonCode(String target) => target;

  @override
  String fromJsonCode(Value value) {
    return '${value.accessor}${value.type.isNullable && !isNullable ? '!' : ''}';
  }

  @override
  String get nameWithoutNullability => 'Object';

  @override
  bool equalsWithoutNullability(other) {
    return other is ObjectType;
  }

  @override
  ValueType copyWith({bool? isNullable}) =>
      ObjectType(isNullable: isNullable ?? this.isNullable);
}

abstract class _SimpleType extends ValueType {
  @override
  final String nameWithoutNullability;

  _SimpleType(this.nameWithoutNullability, {required bool isNullable})
      : super(isNullable: isNullable);

  @override
  String toJsonCode(String target) => target;

  @override
  String fromJsonCode(Value value) {
    if (value.type.equalsWithoutNullability(this)) {
      return access(value);
    } else {
      return '${access(value)} as ${castToThisFrom(value.type)}';
    }
  }

  @override
  bool equalsWithoutNullability(other) {
    return other is _SimpleType &&
        other.runtimeType == runtimeType &&
        nameWithoutNullability == other.nameWithoutNullability;
  }
}

class NumType extends _SimpleType {
  NumType({required bool isNullable}) : super('num', isNullable: isNullable);

  @override
  ValueType copyWith({bool? isNullable}) =>
      NumType(isNullable: isNullable ?? this.isNullable);
}

abstract class _IntDoubleType extends _SimpleType {
  final String castMethod;

  _IntDoubleType(String name, this.castMethod, {required bool isNullable})
      : super(name, isNullable: isNullable);

  @override
  String fromJsonCode(Value value) {
    if (value.type.equalsWithoutNullability(this)) {
      return access(value);
    } else {
      var numType = NumType(isNullable: isNullable);
      return '(${access(value)} as ${numType.castToThisFrom(value.type)})${questionIfNeeded(value.type)}.$castMethod()';
    }
  }
}

class IntType extends _IntDoubleType {
  IntType({required bool isNullable})
      : super('int', 'toInt', isNullable: isNullable);

  @override
  ValueType copyWith({bool? isNullable}) =>
      IntType(isNullable: isNullable ?? this.isNullable);
}

class DoubleType extends _IntDoubleType {
  DoubleType({required bool isNullable})
      : super('double', 'toDouble', isNullable: isNullable);

  @override
  ValueType copyWith({bool? isNullable}) =>
      DoubleType(isNullable: isNullable ?? this.isNullable);
}

class BoolType extends _SimpleType {
  BoolType({required bool isNullable}) : super('bool', isNullable: isNullable);

  @override
  ValueType copyWith({bool? isNullable}) =>
      BoolType(isNullable: isNullable ?? this.isNullable);
}

class StringType extends _SimpleType {
  StringType({bool isNullable = false})
      : super('String', isNullable: isNullable);

  @override
  ValueType copyWith({bool? isNullable}) =>
      StringType(isNullable: isNullable ?? this.isNullable);
}

class ComplexType extends ValueType {
  final String complexName;
  final Map<String, ValueType> genericTypes;

  ComplexType(this.complexName,
      {bool isNullable = false, Map<String, ValueType>? genericTypes})
      : genericTypes = genericTypes ?? const {},
        super(isNullable: isNullable);

  @override
  bool equalsWithoutNullability(other) {
    return other is ComplexType &&
        other.complexName == complexName &&
        const MapEquality().equals(genericTypes, other.genericTypes);
  }

  @override
  String get nameWithoutNullability {
    var name = complexName;
    if (genericTypes.isNotEmpty) {
      name += '<${genericTypes.values.map((t) => t.name).join(', ')}>';
    }
    return name;
  }

  @override
  String fromJsonCode(Value value) {
    var revivers = <String>[];
    for (var genericType in genericTypes.entries) {
      var parameter = genericType.key
          .substring(1)
          .replaceCharAt(0, transformer: (c) => c.toLowerCase());
      revivers.add(
          '${parameter}Reviver: (d) => ${genericType.value.fromJsonCode(Value('d', ObjectType(isNullable: true)))}');
    }

    var reviverCode = '';
    if (revivers.isNotEmpty) {
      reviverCode = ', ${revivers.join(', ')},';
    }
    if (isNullable && value.type.isNullable) {
      return '${value.accessor} != null ? $nameWithoutNullability.fromJson(${jsonMap.fromJsonCode(value.asNonNull)}$reviverCode) : null';
    }

    var accessor = jsonMap.fromJsonCode(value);
    return '$nameWithoutNullability.fromJson($accessor$reviverCode)';
  }

  @override
  String toJsonCode(String target) {
    return '$target${isNullable ? '?' : ''}.toJson()';
  }

  @override
  ValueType copyWith({bool? isNullable}) => ComplexType(complexName,
      isNullable: isNullable ?? this.isNullable, genericTypes: genericTypes);
}

class ListType extends ValueType {
  final ValueType itemType;

  ListType(this.itemType, {bool isNullable = false})
      : super(isNullable: isNullable);

  @override
  bool equalsWithoutNullability(other) {
    return other is ListType && other.itemType == itemType;
  }

  @override
  String get nameWithoutNullability => 'List<${itemType.name}>';

  @override
  String fromJsonCode(Value value) {
    var sourceType = value.type;
    if (sourceType is ObjectType) {
      return fromJsonCode(Value(
          '${access(value)} as List<Object?>${questionIfNeeded(sourceType)}',
          ListType(ObjectType(isNullable: true),
              isNullable: sourceType.isNullable)));
    } else if (sourceType is ListType) {
      var itemVariable = 'i';
      var itemConversion =
          itemType.fromJsonCode(Value(itemVariable, sourceType.itemType));
      if (itemConversion != itemVariable) {
        var code = value.accessor;
        if (code.contains(' ')) {
          code = '($code)';
        }
        return '$code${questionIfNeeded(sourceType)}.map(($itemVariable) => $itemConversion).toList()';
      }
      return value.accessor;
    } else {
      throw Exception("Can't convert $sourceType to List");
    }
  }

  @override
  String toJsonCode(String target) {
    var itemVariable = 'i';
    var itemConversion = itemType.toJsonCode(itemVariable);
    if (itemConversion != itemVariable) {
      return '$target$questionMark.map(($itemVariable) => $itemConversion).toList()';
    } else {
      return target;
    }
  }

  @override
  ValueType copyWith({bool? isNullable}) =>
      ListType(itemType, isNullable: isNullable ?? this.isNullable);
}

final jsonMap = MapType(
    StringType(isNullable: false), ObjectType(isNullable: true),
    isNullable: false);
final jsonMapNullable = MapType(
    StringType(isNullable: false), ObjectType(isNullable: true),
    isNullable: true);

class MapType extends ValueType {
  final ValueType keyType, valueType;

  MapType(this.keyType, this.valueType, {bool isNullable = false})
      : super(isNullable: isNullable);

  @override
  bool equalsWithoutNullability(other) {
    return other is MapType &&
        other.keyType == keyType &&
        other.valueType == valueType;
  }

  @override
  String get nameWithoutNullability =>
      'Map<${keyType.name}, ${valueType.name}>';

  @override
  String fromJsonCode(Value value) {
    var sourceType = value.type;
    if (sourceType is ObjectType) {
      return fromJsonCode(Value(
          '${access(value)} as Map<String, Object?>${questionIfNeeded(sourceType)}',
          MapType(StringType(), ObjectType(isNullable: true),
              isNullable: sourceType.isNullable)));
    } else if (sourceType is MapType) {
      var keyVariable = 'k';
      var valueVariable = 'v';
      var keyConversion =
          keyType.fromJsonCode(Value(keyVariable, sourceType.keyType));
      var valueConversion =
          valueType.fromJsonCode(Value(valueVariable, sourceType.valueType));
      if (keyConversion != keyVariable || valueConversion != valueVariable) {
        var code = value.accessor;
        if (code.contains(' ')) {
          code = '($code)';
        }
        return '$code${questionIfNeeded(value.type)}.map(($keyVariable, $valueVariable) => MapEntry($keyConversion, $valueConversion))';
      }
      return value.accessor;
    } else {
      throw Exception("Can't convert $sourceType to Map");
    }
  }

  @override
  String toJsonCode(String target) {
    var keyVariable = 'k';
    var keyConversion = keyType.toJsonCode(keyVariable);
    var valueVariable = 'v';
    var valueConversion = valueType.toJsonCode(valueVariable);
    if (keyConversion != keyVariable || valueConversion != valueVariable) {
      return '$target$questionMark.map(($keyVariable, $valueVariable) => MapEntry($keyConversion, $valueConversion))';
    } else {
      return target;
    }
  }

  @override
  ValueType copyWith({bool? isNullable}) =>
      MapType(keyType, valueType, isNullable: isNullable ?? this.isNullable);
}

class EnumType extends ValueType {
  @override
  final String nameWithoutNullability;

  EnumType(this.nameWithoutNullability, {required bool isNullable})
      : super(isNullable: isNullable);

  @override
  String toJsonCode(String target) => 'apiUtils.enumName($target)';

  @override
  String fromJsonCode(Value value) {
    var castCode = '';
    if (value.type is! StringType) {
      var stringType = StringType(isNullable: isNullable);
      castCode = ' as ${stringType.castToThisFrom(value.type)}';
    }
    return 'apiUtils.enumFrom(${access(value)}$castCode, $nameWithoutNullability.values)${!isNullable ? '!' : ''}';
  }

  @override
  bool equalsWithoutNullability(other) {
    return other.runtimeType == runtimeType &&
        nameWithoutNullability == nameWithoutNullability;
  }

  @override
  ValueType copyWith({bool? isNullable}) => EnumType(nameWithoutNullability,
      isNullable: isNullable ?? this.isNullable);
}

class DateTimeType extends _SimpleType {
  DateTimeType({required bool isNullable})
      : super('DateTime', isNullable: isNullable);

  @override
  String toJsonCode(String target) =>
      '$target${isNullable ? '?' : ''}.toIso8601String()';

  @override
  String fromJsonCode(Value value) {
    var castCode = '';
    if (value.type is! StringType) {
      var stringType = StringType(isNullable: isNullable);
      castCode = ' as ${stringType.castToThisFrom(value.type)}';
    }
    return 'DateTime.${isNullable ? 'tryParse' : 'parse'}(${access(value)}$castCode)';
  }

  @override
  ValueType copyWith({bool? isNullable}) =>
      DateTimeType(isNullable: isNullable ?? this.isNullable);
}
