import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as p;
import '../utils/string.dart';
import 'package:collection/collection.dart';

import 'utils.dart';

Future<String> generateOpenApiSchema(
  List<Api> apis, {
  required String title,
  required String description,
  required String version,
}) async {
  var collection = AnalysisContextCollection(
    includedPaths:
        apis.map((a) => p.normalize(a.file.absolute.path)).toSet().toList(),
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
  var contexts = collection.contexts;
  var builder = _SchemaBuilder(contexts[0], apis);
  await builder.build();

  var schema = <String, dynamic>{
    'openapi': '3.0.0',
    'info': {
      'title': 'Fluidra EMEA IoT Consumer API',
      'description': 'API for Consumer mobile app (iAquaLink+)',
      'version': '0.0.1',
    },
    'paths': builder.paths,
    'components': {
      'responses': {
        'Error': {
          'description': 'Generic error',
          'content': {
            'application/json': {
              'schema': {
                'type': 'object',
              }
            }
          },
        },
      },
      'schemas': builder.schemas,
    },
  };

  // Steps:
  // - Add "enum" property for enum & enum-like class
  //     => enum like with only one "code", should be encoded as "string"
  // -

  return const JsonEncoder.withIndent('  ').convert(schema);
}

class _SchemaBuilder {
  final AnalysisContext _context;
  final List<Api> _apis;
  final paths = <String, dynamic>{};
  final schemas = <String, dynamic>{};

  _SchemaBuilder(this._context, this._apis);

  Future<void> build() async {
    const apiMetaName = 'Api';
    for (var api in _apis) {
      var result = await _context.currentSession
              .getResolvedUnit(p.normalize(api.file.absolute.path))
          as ResolvedUnitResult;
      var apiClass = result.unit.declarations
          .whereType<ClassDeclaration>()
          .where((c) => c.metadata.any((m) => m.name.name == apiMetaName))
          .where((c) => api.className == null || c.name.name == api.className)
          .single;

      var apiMeta =
          apiClass.metadata.firstWhere((m) => m.name.name == apiMetaName);
      var basePath =
          (apiMeta.arguments!.arguments.first as StringLiteral).stringValue!;

      for (var method in apiClass.members.whereType<MethodDeclaration>()) {
        var methodElement = method.declaredElement! as MethodElement;
        var meta = method.metadata.firstWhereOrNull(
            (m) => const ['Get', 'Post', 'Delete'].contains(m.name.name));
        if (meta != null) {
          var httpMethod = meta.name.name.toLowerCase();
          var methodPath = method.name.name.words.toLowerHyphen();

          var returnType = method.returnType?.type;
          Map<String, dynamic>? response;
          if (returnType != null && !isVoid(returnType)) {
            response = {
              'application/json': {
                'schema': _schemaForType(returnType),
              },
            };
          }

          Object? parameters;
          Object? requestBody;
          if (const ['get', 'delete'].contains(httpMethod)) {
            var parameters = [];
            for (var parameter in methodElement.parameters) {
              parameters.add({
                'in': 'query',
                'required':
                    parameter.type.nullabilitySuffix == NullabilitySuffix.none,
                'schema': _schemaForType(parameter.type),
              });
            }
          } else {
            var requiredList = methodElement.parameters
                .where(
                    (p) => p.type.nullabilitySuffix == NullabilitySuffix.none)
                .map((p) => p.name)
                .toList();
            requestBody = {
              'required': true,
              'content': {
                'application/json': {
                  'schema': {
                    'type': 'object',
                    if (requiredList.isNotEmpty) 'required': requiredList,
                    'properties': {
                      for (var parameter in methodElement.parameters)
                        parameter.name: _schemaForType(parameter.type),
                    },
                  }
                }
              },
            };
          }

          var comment = method.documentationComment;
          paths['/${p.url.join(basePath, methodPath)}'] = {
            httpMethod: {
              if (comment != null)
                'description': comment.tokens
                    .map((l) => l.toString().substring(4))
                    .join('\n'),
              if (parameters != null) 'parameters': parameters,
              if (requestBody != null) 'requestBody': requestBody,
              'responses': {
                '200': {
                  'description': 'Success',
                  if (response != null) 'content': response,
                },
                '500': {r'$ref': '#/components/responses/Error'},
              },
            },
          };
        }
      }
    }
  }

  Map<String, dynamic> _schemaForType(DartType type) {
    type = futureType(type);
    Map<String, dynamic> simpleType(String typeName) {
      return {'type': typeName};
    }

    if (type.isDartCoreInt) {
      return simpleType('integer');
    } else if (type.isDartCoreDouble || type.isDartCoreNum) {
      return simpleType('number');
    } else if (type.isDartCoreBool) {
      return simpleType('boolean');
    } else if (type.isDartCoreString) {
      return simpleType('string');
    } else if (isDateTime(type)) {
      return {'type': 'string', 'format': 'date-time'};
    } else if (type.isDartCoreList) {
      Object? items;
      if (type is ParameterizedType) {
        items = _schemaForType(type.typeArguments.first);
      }
      return {
        'type': 'array',
        if (items != null) 'items': items,
      };
    } else if (type.isDartCoreMap) {
      return {'type': 'object'};
    } else {
      return {
        r'$ref': _addSchema(type),
      };
    }
  }

  String _addSchema(DartType type) {
    var typeName = type.getDisplayString(withNullability: false);
    if (!schemas.containsKey(typeName)) {
      var element = type.element!;
      if (element is ClassElement) {
        if (element.isEnum) {
          schemas[typeName] = {
            'type': 'string',
            'enum': [],
          };
        } else {
          var fields = element.fields.where((e) => !e.isStatic);
          var required = fields
              .where((f) => f.type.nullabilitySuffix == NullabilitySuffix.none)
              .map((f) => f.name)
              .toList();

          var description = schemas[typeName] = {
            'type': 'object',
            if (required.isNotEmpty) 'required': required,
          };
          description['properties'] = {
            for (var field in fields) field.name: _schemaForType(field.type),
          };
        }
      }
    }

    return '#/components/schemas/$typeName';
  }
}

class Api {
  final File file;
  final String? className;

  Api(String file, {this.className}) : file = File(file);
}
