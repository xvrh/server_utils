import 'package:test/test.dart';
import 'package:server_utils/src/utils/type.dart';

void main() {
  final object = ObjectType(isNullable: false);
  final nullableObject = ObjectType(isNullable: true);

  test('object type', () {
    expect(ObjectType(isNullable: true), ObjectType(isNullable: true));
    expect(ObjectType(isNullable: false), ObjectType(isNullable: false));
    expect(ObjectType(isNullable: true), isNot(ObjectType(isNullable: false)));
    expect(ObjectType(isNullable: false).toJsonCode('v'), 'v');
    expect(ObjectType(isNullable: true).toJsonCode('v'), 'v');
  });
  test('object fromJson', () {
    var nullable = ObjectType(isNullable: true);
    var nonNullable = ObjectType(isNullable: false);
    var vNn = Value('v', nonNullable);
    var vNull = Value('v', nullable);

    expect(nonNullable.fromJsonCode(vNn), 'v');
    expect(nonNullable.fromJsonCode(vNull), 'v!');
    expect(nullable.fromJsonCode(vNn), 'v');
    expect(nullable.fromJsonCode(vNull), 'v');
    expect(nullable.fromJsonCode(Value('o', NumType(isNullable: false))), 'o');
    expect(nullable.fromJsonCode(Value('o', NumType(isNullable: true))), 'o');
    expect(
        nonNullable.fromJsonCode(Value('o', NumType(isNullable: false))), 'o');
    expect(
        nonNullable.fromJsonCode(Value('o', NumType(isNullable: true))), 'o!');
  });
  test('num toJson', () {
    expect(NumType(isNullable: false).toJsonCode('v'), 'v');
    expect(NumType(isNullable: true).toJsonCode('v'), 'v');
  });
  test('num fromJson', () {
    var nullable = NumType(isNullable: true);
    var nonNullable = NumType(isNullable: false);
    var vNn = Value('v', nonNullable);
    var vNull = Value('v', nullable);

    expect(nonNullable.fromJsonCode(vNn), 'v');
    expect(nonNullable.fromJsonCode(vNull), 'v!');
    expect(nullable.fromJsonCode(vNn), 'v');
    expect(nullable.fromJsonCode(vNull), 'v');
    expect(nullable.fromJsonCode(Value('o', object)), 'o as num');
    expect(nullable.fromJsonCode(Value('o', nullableObject)), 'o as num?');
    expect(nonNullable.fromJsonCode(Value('o', object)), 'o as num');
    expect(nonNullable.fromJsonCode(Value('o', nullableObject)), 'o! as num');
  });
  test('int toJson', () {
    expect(IntType(isNullable: false).toJsonCode('v'), 'v');
    expect(IntType(isNullable: true).toJsonCode('v'), 'v');
  });
  test('int fromJson', () {
    var nullable = IntType(isNullable: true);
    var nonNullable = IntType(isNullable: false);
    var vNn = Value('v', nonNullable);
    var vNull = Value('v', nullable);

    expect(nonNullable.fromJsonCode(vNn), 'v');
    expect(nonNullable.fromJsonCode(vNull), 'v!');
    expect(nullable.fromJsonCode(vNn), 'v');
    expect(nullable.fromJsonCode(vNull), 'v');
    expect(nullable.fromJsonCode(Value('o', object)), '(o as num).toInt()');
    expect(nullable.fromJsonCode(Value('o', nullableObject)),
        '(o as num?)?.toInt()');
    expect(nonNullable.fromJsonCode(Value('o', object)), '(o as num).toInt()');
    expect(nonNullable.fromJsonCode(Value('o', nullableObject)),
        '(o! as num).toInt()');
  });
  test('double type', () {
    expect(DoubleType(isNullable: true), DoubleType(isNullable: true));
    expect(DoubleType(isNullable: false), DoubleType(isNullable: false));
    expect(DoubleType(isNullable: true), isNot(DoubleType(isNullable: false)));
    expect(DoubleType(isNullable: true), isNot(NumType(isNullable: true)));
    expect(DoubleType(isNullable: false).toJsonCode('v'), 'v');
    expect(DoubleType(isNullable: true).toJsonCode('v'), 'v');
  });
  test('double fromJson', () {
    var nullable = DoubleType(isNullable: true);
    var nonNullable = DoubleType(isNullable: false);
    var vNn = Value('v', nonNullable);
    var vNull = Value('v', nullable);

    expect(nonNullable.fromJsonCode(vNn), 'v');
    expect(nonNullable.fromJsonCode(vNull), 'v!');
    expect(nullable.fromJsonCode(vNn), 'v');
    expect(nullable.fromJsonCode(vNull), 'v');
    expect(nullable.fromJsonCode(Value('o', object)), '(o as num).toDouble()');
    expect(nullable.fromJsonCode(Value('o', nullableObject)),
        '(o as num?)?.toDouble()');
    expect(
        nonNullable.fromJsonCode(Value('o', object)), '(o as num).toDouble()');
    expect(nonNullable.fromJsonCode(Value('o', nullableObject)),
        '(o! as num).toDouble()');
  });
  test('bool type', () {
    expect(BoolType(isNullable: true), BoolType(isNullable: true));
    expect(BoolType(isNullable: false), BoolType(isNullable: false));
    expect(BoolType(isNullable: true), isNot(BoolType(isNullable: false)));
    expect(BoolType(isNullable: true), isNot(ObjectType(isNullable: true)));
    expect(BoolType(isNullable: false).toJsonCode('v'), 'v');
    expect(BoolType(isNullable: true).toJsonCode('v'), 'v');
  });
  test('bool fromJson', () {
    var nullable = BoolType(isNullable: true);
    var nonNullable = BoolType(isNullable: false);
    var vNn = Value('v', nonNullable);
    var vNull = Value('v', nullable);

    expect(nonNullable.fromJsonCode(vNn), 'v');
    expect(nonNullable.fromJsonCode(vNull), 'v!');
    expect(nullable.fromJsonCode(vNn), 'v');
    expect(nullable.fromJsonCode(vNull), 'v');
    expect(nullable.fromJsonCode(Value('o', object)), 'o as bool');
    expect(nullable.fromJsonCode(Value('o', nullableObject)), 'o as bool?');
    expect(nonNullable.fromJsonCode(Value('o', object)), 'o as bool');
    expect(nonNullable.fromJsonCode(Value('o', nullableObject)), 'o! as bool');
  });
  test('string type', () {
    expect(StringType(isNullable: true), StringType(isNullable: true));
    expect(StringType(isNullable: false), StringType(isNullable: false));
    expect(StringType(isNullable: true), isNot(StringType(isNullable: false)));
    expect(StringType(isNullable: true), isNot(ObjectType(isNullable: true)));
    expect(StringType(isNullable: false).toJsonCode('v'), 'v');
    expect(StringType(isNullable: true).toJsonCode('v'), 'v');
  });
  test('string fromJson', () {
    var nullable = StringType(isNullable: true);
    var nonNullable = StringType(isNullable: false);
    var vNn = Value('v', nonNullable);
    var vNull = Value('v', nullable);

    expect(nonNullable.fromJsonCode(vNn), 'v');
    expect(nonNullable.fromJsonCode(vNull), 'v!');
    expect(nullable.fromJsonCode(vNn), 'v');
    expect(nullable.fromJsonCode(vNull), 'v');
    expect(nullable.fromJsonCode(Value('o', object)), 'o as String');
    expect(nullable.fromJsonCode(Value('o', nullableObject)), 'o as String?');
    expect(nonNullable.fromJsonCode(Value('o', object)), 'o as String');
    expect(
        nonNullable.fromJsonCode(Value('o', nullableObject)), 'o! as String');
  });
  test('complex type fromJson', () {
    var someType = ComplexType('Some', isNullable: false);
    var someTypeNullable = ComplexType('Some', isNullable: true);
    expect(someType.fromJsonCode(Value('v', jsonMap)), 'Some.fromJson(v)');
    expect(someType.fromJsonCode(Value('v', ObjectType(isNullable: true))),
        'Some.fromJson(v! as Map<String, Object?>)');
    expect(someType.fromJsonCode(Value('v', ObjectType(isNullable: false))),
        'Some.fromJson(v as Map<String, Object?>)');
    expect(
        someTypeNullable.fromJsonCode(Value('v', ObjectType(isNullable: true))),
        'v != null ? Some.fromJson(v as Map<String, Object?>) : null');
    expect(
        someTypeNullable
            .fromJsonCode(Value('v', ObjectType(isNullable: false))),
        'Some.fromJson(v as Map<String, Object?>)');
  });
  test('complex type from json with generic type', () {
    var type =
        ComplexType('Page', genericTypes: {'TContent': ComplexType('Product')});
    expect(type.name, 'Page<Product>');
    expect(type.fromJsonCode(Value('v', jsonMap)),
        'Page<Product>.fromJson(v, contentReviver: (d) => Product.fromJson(d! as Map<String, Object?>),)');
  });
  test('complex type toJson', () {
    var someType = ComplexType('Some', isNullable: false);
    var someTypeNullable = ComplexType('Some', isNullable: true);

    expect(someType.toJsonCode('v'), 'v.toJson()');
    expect(someTypeNullable.toJsonCode('v'), 'v?.toJson()');
  });
  test('list toJson simpletype', () {
    expect(ListType(StringType()).toJsonCode('v'), 'v');
    expect(ListType(StringType(), isNullable: true).toJsonCode('v'), 'v');
    expect(
        ListType(StringType(isNullable: true), isNullable: true)
            .toJsonCode('v'),
        'v');
  });
  test('list toJson complex type non nullable 1', () {
    var list = ListType(ComplexType('Some'));
    expect(list.toJsonCode('v'), 'v.map((i) => i.toJson()).toList()');
  });
  test('list toJson complex type non nullable 2', () {
    var list = ListType(ComplexType('Some', isNullable: true));
    expect(list.toJsonCode('v'), 'v.map((i) => i?.toJson()).toList()');
  });
  test('list toJson complex type nullable 1', () {
    var list = ListType(ComplexType('Some'), isNullable: true);
    expect(list.toJsonCode('v'), 'v?.map((i) => i.toJson()).toList()');
  });
  test('list toJson complex type nullable 2', () {
    var list =
        ListType(ComplexType('Some', isNullable: true), isNullable: true);
    expect(list.toJsonCode('v'), 'v?.map((i) => i?.toJson()).toList()');
  });
  test('list of list toJson complex type non nullable 1', () {
    var list = ListType(ListType(ComplexType('Some')));
    expect(list.toJsonCode('v'),
        'v.map((i) => i.map((i) => i.toJson()).toList()).toList()');
  });
  test('list fromJson 1', () {
    var list = ListType(ComplexType('Some'));
    expect(list.fromJsonCode(Value('v', ObjectType())),
        '(v as List<Object?>).map((i) => Some.fromJson(i! as Map<String, Object?>)).toList()');
  });
  test('list fromJson 2', () {
    var list = ListType(ComplexType('Some', isNullable: true));
    expect(list.fromJsonCode(Value('v', ObjectType())),
        '(v as List<Object?>).map((i) => i != null ? Some.fromJson(i as Map<String, Object?>) : null).toList()');
  });
  test('map toJson', () {
    expect(MapType(StringType(), StringType()).toJsonCode('v'), 'v');
    expect(MapType(StringType(), ComplexType('MyType')).toJsonCode('v'),
        'v.map((k, v) => MapEntry(k, v.toJson()))');
  });
  test('map from json nullable', () {
    var target = MapType(StringType(), StringType(), isNullable: true);
    var source = ObjectType(isNullable: true);
    expect(target.fromJsonCode(Value('v', source)),
        '(v as Map<String, Object?>?)?.map((k, v) => MapEntry(k, v! as String))');
  });
  test('map from json non nullable', () {
    var target = MapType(StringType(), StringType());
    var source = ObjectType(isNullable: false);
    expect(target.fromJsonCode(Value('v', source)),
        '(v as Map<String, Object?>).map((k, v) => MapEntry(k, v! as String))');
  });
  test('map from json complex type', () {
    var target = MapType(StringType(), ComplexType('Type'));
    var source = ObjectType(isNullable: false);
    expect(target.fromJsonCode(Value('v', source)),
        '(v as Map<String, Object?>).map((k, v) => MapEntry(k, Type.fromJson(v! as Map<String, Object?>)))');
  });
  test('map fromJson enum non null', () {
    var target = MapType(EnumType('MyEnum', isNullable: false), StringType());
    var source = ObjectType(isNullable: false);
    expect(target.fromJsonCode(Value('v', source)),
        '(v as Map<String, Object?>).map((k, v) => MapEntry(apiUtils.enumFrom(k, MyEnum.values)!, v! as String))');
  });
  test('map fromJson enum null', () {
    var target = MapType(EnumType('MyEnum', isNullable: true), StringType());
    var source = ObjectType(isNullable: true);
    expect(target.fromJsonCode(Value('v', source)),
        '(v! as Map<String, Object?>).map((k, v) => MapEntry(apiUtils.enumFrom(k, MyEnum.values), v! as String))');
  });
  test('map fromJson enum null target null', () {
    var target = MapType(EnumType('MyEnum', isNullable: true), StringType(),
        isNullable: true);
    var source = ObjectType(isNullable: true);
    expect(target.fromJsonCode(Value('v', source)),
        '(v as Map<String, Object?>?)?.map((k, v) => MapEntry(apiUtils.enumFrom(k, MyEnum.values), v! as String))');
  });
  test('Enum toJson nullable', () {
    var source = EnumType('MyEnum', isNullable: true);
    expect(source.toJsonCode('v'), 'apiUtils.enumName(v)');
  });
  test('Enum toJson non nullable', () {
    var source = EnumType('MyEnum', isNullable: false);
    expect(source.toJsonCode('v'), 'apiUtils.enumName(v)');
  });
  test('DateTime toJson non nullable', () {
    var source = DateTimeType(isNullable: false);
    expect(source.toJsonCode('v'), 'v.toIso8601String()');
  });
  test('DateTime toJson nullable', () {
    var source = DateTimeType(isNullable: true);
    expect(source.toJsonCode('v'), 'v?.toIso8601String()');
  });
  test('DateTime fromJson non nullable', () {
    var source = DateTimeType(isNullable: false);
    expect(source.fromJsonCode(Value('v', ObjectType())),
        'DateTime.parse(v as String)');
  });
  test('DateTime fromJson nullable 1', () {
    var source = DateTimeType(isNullable: true);
    expect(source.fromJsonCode(Value('v', ObjectType())),
        'DateTime.tryParse(v as String)');
  });
  test('DateTime fromJson nullable 2', () {
    var source = DateTimeType(isNullable: true);
    expect(source.fromJsonCode(Value('v', ObjectType(isNullable: true))),
        "DateTime.tryParse(v as String? ?? '')");
  });
  test('Object to dynamic', () {
    var source = DynamicType();
    expect(source.fromJsonCode(Value('v', ObjectType(isNullable: false))), 'v');
  });
  test('Object? to dynamic', () {
    var source = DynamicType();
    expect(source.fromJsonCode(Value('v', ObjectType(isNullable: true))), 'v');
  });
  test('dynamic to Object!', () {
    var source = ObjectType();
    expect(source.fromJsonCode(Value('v', DynamicType())), 'v! as Object');
  });
  test('dynamic to Object?', () {
    var source = ObjectType(isNullable: true);
    expect(source.fromJsonCode(Value('v', DynamicType())), 'v as Object?');
  });
  test('Object? to Object!', () {
    var source = ObjectType();
    expect(source.fromJsonCode(Value('v', ObjectType(isNullable: true))), 'v!');
  });
  test('Object? to Object?', () {
    var source = ObjectType(isNullable: true);
    expect(source.fromJsonCode(Value('v', ObjectType(isNullable: true))), 'v');
  });
}
