import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
//ignore: implementation_imports
import 'package:analyzer/src/dart/element/type.dart' show DynamicTypeImpl;
import 'package:source_gen/source_gen.dart';
import 'annotations.dart';

final pathParamPattern = RegExp(r'\{([^}]+)\}');

List<String> extractPathParameters(String path) {
  return pathParamPattern.allMatches(path).map((m) => m.group(1)!).toList();
}

Api readApiAnnotation(ConstantReader reader) =>
    Api(reader.read('path').stringValue);

DartObject? findActionAnnotation(MethodElement element) {
  return const TypeChecker.fromRuntime(Action).firstAnnotationOf(element);
}

bool hasFromJsonMethod(DartType type) {
  if (type.element2 is! ClassElement) return false;

  var classElement = type.element2! as ClassElement;

  return classElement.getNamedConstructor('fromJson') != null ||
      classElement.getMethod('fromJson') != null;
}

bool isDateTime(DartType type) =>
    type.element2 != null &&
    type.element2!.library != null &&
    type.element2!.library!.isDartCore &&
    type.getDisplayString(withNullability: false) == 'DateTime';

bool isEnum(DartType type) {
  return type.element2 is EnumElement;
}

bool isJsonSimpleType(DartType type) =>
    type.isDartCoreInt ||
    type.isDartCoreDouble ||
    type.isDartCoreBool ||
    type.isDartCoreString ||
    type.isDartCoreNum;

bool isVoid(DartType type) =>
    type.isVoid ||
    type.getDisplayString(withNullability: true) == 'Future<void>';

DartType futureType(DartType type) {
  if (type.isDartAsyncFuture && type is ParameterizedType) {
    if (type.typeArguments.isNotEmpty) return type.typeArguments.first;
    return DynamicTypeImpl.instance;
  }
  return type;
}

String encodeParameters(List<ParameterElement> parameters) {
  var positional = parameters.where((p) => !p.isNamed).toList();
  var named = parameters.where((p) => p.isNamed).toList();

  var namedCode = '';
  if (named.isNotEmpty) {
    if (positional.isNotEmpty) {
      namedCode = ', ';
    }
    namedCode +=
        '{${named.map((p) => '${p.isRequiredNamed ? 'required' : ''} ${p.type} ${p.name}').join(', ')}}';
  }

  return '${positional.join(', ')}$namedCode';
}
