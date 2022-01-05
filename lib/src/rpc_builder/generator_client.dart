import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:server_utils/src/rpc_builder/type.dart';
import 'annotations.dart';
import 'type_dart.dart';
import 'utils.dart';

final _dartFormatter = DartFormatter();

class RpcClientGenerator extends GeneratorForAnnotation<Api> {
  const RpcClientGenerator();

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError('Generator cannot target `$name`.',
          todo: 'Remove the @Api annotation from `$name`.', element: element);
    }
    var classElement = element;
    var className = classElement.name;
    className = className.replaceAll(RegExp(r'Api$'), 'Client');

    var apiAnnotation = readApiAnnotation(annotation);

    var code = StringBuffer();

    var extraImports = <_Import>[];

    for (var method in classElement.methods) {
      var actionAnnotation = findActionAnnotation(method);
      if (actionAnnotation != null) {
        var actionType = actionAnnotation.type!
            .getDisplayString(withNullability: true)
            .toLowerCase();

        _importsForType(method.returnType, extraImports);
        for (var parameter in method.parameters) {
          _importsForType(parameter.type, extraImports);
        }

        code.writeln(
            '''Future<${futureType(method.returnType)}> ${method.name}(${encodeParameters(method.parameters)}) async {
          var \$url = Uri.parse(path_helper.url.join(_basePath, '${apiAnnotation.path}', '${method.name}'));''');

        var queryParameters = method.parameters;
        String sendCode;
        if (const ['get', 'delete'].contains(actionType)) {
          sendCode = 'await _client.$actionType(\$url)';
        } else {
          queryParameters = [];
          var bodyParameters = method.parameters.toList();

          var body = '';
          if (bodyParameters.isNotEmpty) {
            body = ', body: jsonEncode({';
            for (var parameter in bodyParameters) {
              body += "'${parameter.name}': ";
              body +=
                  '${typeFromDart(parameter.type).toJsonCode(parameter.name)},\n';
            }
            body += '})';
          }

          sendCode = 'await _client.$actionType(\$url$body)';
        }

        if (queryParameters.isNotEmpty) {
          code.writeln(r'$url = $url.replace(queryParameters: {');

          for (var parameter in queryParameters) {
            if (parameter.type.nullabilitySuffix ==
                NullabilitySuffix.question) {
              code.writeln('if (${parameter.name} != null)');
            }

            String encodedParameter;

            if (parameter.type.isDartCoreString) {
              encodedParameter = parameter.name;
            } else if (parameter.type.isDartCoreBool ||
                parameter.type.isDartCoreInt ||
                parameter.type.isDartCoreDouble ||
                parameter.type.isDartCoreNum ||
                isDateTime(parameter.type) ||
                isEnum(parameter.type)) {
              encodedParameter = '${parameter.name}.toString()';
            } else {
              var parameterType = typeFromDart(parameter.type);
              encodedParameter =
                  'jsonEncode(${parameterType.toJsonCode(parameter.name)})';
            }

            code.writeln("'${parameter.name}': $encodedParameter,");
          }

          code.writeln('});');
        }

        code.writeln('''
          var \$response = $sendCode;
          checkResponseSuccess(\$url, \$response);''');

        if (!isVoid(method.returnType)) {
          var returnType = typeFromDart(futureType(method.returnType));
          code.writeln('''
          var \$decodedResponse = jsonDecode(\$response.body);
          return ${returnType.fromJsonCode(Value(r'$decodedResponse', ObjectType(isNullable: true)))};
        ''');
        }

        code.writeln('}');
        code.writeln('');
      }
    }

    var groupedImports = <String>[];
    var groupedExports = <String>[];
    var thisUri = classElement.source.uri;
    for (var importUri in extraImports.map((i) => i.uri).toSet()) {
      var shows = extraImports
          .where((i) => i.uri == importUri)
          .map((i) => i.showType)
          .toSet()
          .join(', ');
      if (importUri.scheme == 'asset') {
        importUri = Uri.parse(
            p.relative(importUri.path, from: p.dirname(thisUri.path)));
      }

      groupedImports.add("import '$importUri' show $shows;");
      groupedExports.add("export '$importUri' show $shows;");
    }

    var fileCode = '''
// GENERATED-CODE: do not edit
// This code is generated by the rpc_builder tool
    
import 'dart:convert';
import 'package:http/http.dart';
import 'package:path/path.dart' as path_helper;
import 'package:server_utils/rpc_client.dart';
${groupedImports.join('\n')}

${groupedExports.join('\n')}
 
class $className {
  final Client _client;
  final String _basePath;
  
  $className(this._client, {required String basePath}): _basePath = basePath;
  
  void close() => _client.close();

$code
}
''';

    return _dartFormatter.format(fileCode);
  }
}

void _importsForType(DartType type, List<_Import> imports) {
  if (type is ParameterizedType) {
    for (var typeArgument in type.typeArguments) {
      _importsForType(typeArgument, imports);
    }
  }
  if (type.element != null &&
      type.element!.library != null &&
      !type.element!.library!.isDartCore &&
      type.element!.name != 'Future') {
    var element = type.element;
    if (element is ClassElement) {
      var uri = element.source.uri;
      imports.add(_Import(uri, element.name));
    }
  }
}

class _Import {
  final Uri uri;
  final String showType;

  _Import(this.uri, this.showType);
}
