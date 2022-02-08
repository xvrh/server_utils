import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:more/char_matcher.dart';
import 'package:source_gen/source_gen.dart';
import '../utils/string.dart';
import '../utils/type.dart';
import 'annotations.dart';
import 'type_dart.dart';
import 'utils.dart';

class RpcRouterGenerator extends GeneratorForAnnotation<Api> {
  const RpcRouterGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError('Generator cannot target `$name`.',
          todo: 'Remove the @Api annotation from `$name`.', element: element);
    }
    var apiAnnotation = readApiAnnotation(annotation);

    var classElement = element;
    final className = classElement.name;

    var code = StringBuffer();

    var trimmedPath = CharMatcher.charSet('/').trimFrom(apiAnnotation.path);
    var infoVariableName = '\$${className.words.toLowerCamel()}';
    var factoryVariableName = '_\$${className}Handler';

    code.writeln('''
const $infoVariableName = Api<$className>.info(path: '/$trimmedPath/', name: '$className', factory: $factoryVariableName);    

Handler $factoryVariableName($className api) {
  var router = createRpcRouter($infoVariableName);
''');

    for (var method in classElement.methods) {
      var actionAnnotation = findActionAnnotation(method);
      if (actionAnnotation != null) {
        var actionType = actionAnnotation.type!
            .getDisplayString(withNullability: true)
            .toLowerCase();

        var methodContent = StringBuffer();

        methodContent.writeln('api.${method.name}(');

        var needBody = false;
        for (var parameter in method.parameters) {
          var isNullable =
              parameter.type.nullabilitySuffix == NullabilitySuffix.question;
          var parameterType = typeFromDart(parameter.type);

          String getter;
          if (const ['get', 'delete'].contains(actionType)) {
            var castMethod =
                _castMethodForType(parameter.type, isNullable: isNullable);
            getter = "request.queryParameter('${parameter.name}').$castMethod";

            if (castMethod.endsWith('Json')) {
              getter = parameterType.fromJsonCode(
                  Value(getter, ObjectType(isNullable: isNullable)));
            }
          } else {
            needBody = true;
            getter = "body['${parameter.name}']";
            getter = parameterType
                .fromJsonCode(Value(getter, ObjectType(isNullable: true)));
          }

          if (parameter.isNamed) {
            methodContent.writeln('${parameter.name}: $getter, ');
          } else {
            methodContent.writeln('$getter, ');
          }
        }

        methodContent.writeln(')');

        var endpointName = method.name.words.toLowerHyphen();
        code.writeln('''
router.$actionType('$endpointName', (request) ${(needBody || method.returnType.isDartAsyncFuture) ? 'async' : ''} {
        ''');
        if (needBody) {
          code.writeln('var body = await request.body;');
        }

        var methodContentCode = methodContent.toString();

        var flattedReturn = futureType(method.returnType);
        var isReturnVoid = flattedReturn.isVoid;

        var awaitKeyword = method.returnType.isDartAsyncFuture ? 'await' : '';
        if (!isReturnVoid) {
          var returnType = typeFromDart(flattedReturn);
          code.writeln('var result = $awaitKeyword $methodContentCode;');
          code.writeln('return ${returnType.toJsonCode('result')};');
        } else {
          code.writeln('$awaitKeyword $methodContentCode;');
        }

        code.writeln('});');
      }

      code.writeln('');
    }

    code.writeln('''
  return router.handler;
}''');

    return code.toString();
  }
}

String _castMethodForType(DartType type, {required bool isNullable}) {
  var methodPrefix = isNullable ? 'nullable' : 'required';
  if (type.isDartCoreString) {
    return '${methodPrefix}String()';
  } else if (type.isDartCoreInt) {
    return '${methodPrefix}Int()';
  } else if (isNum(type)) {
    return '${methodPrefix}Num()';
  } else if (type.isDartCoreDouble) {
    return '${methodPrefix}Double()';
  } else if (type.isDartCoreBool) {
    return '${methodPrefix}Bool()';
  } else if (isDateTime(type)) {
    return '${methodPrefix}DateTime()';
  } else if (isEnum(type)) {
    return '${methodPrefix}Enum($type.values)';
  } else {
    return '${methodPrefix}Json';
  }
}
