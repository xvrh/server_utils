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
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import '../utils/string.dart';
import 'utils.dart';

Future<Map<String, dynamic>> generateOpenApiSchema(
  List<Api> apis, {
  required String title,
  required String description,
  required String version,
  UrlReplacement? Function(String)? urlReplacer,
}) async {
  var collection = AnalysisContextCollection(
    includedPaths:
        apis.map((a) => p.normalize(a.file.absolute.path)).toSet().toList(),
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
  var contexts = collection.contexts;
  var builder = _SchemaBuilder(contexts[0], apis, urlReplacer);
  await builder.build();

  var schema = <String, dynamic>{
    'openapi': '3.0.0',
    'info': {
      'title': title,
      'description': description,
      'version': version,
    },
    'tags': builder.tags,
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

  return schema;
}

class _SchemaBuilder {
  final AnalysisContext _context;
  final List<Api> _apis;
  final paths = <String, Map<String, dynamic>>{};
  final schemas = <String, dynamic>{};
  final tags = <Map<String, dynamic>>[];
  final UrlReplacement? Function(String)? urlReplacer;

  _SchemaBuilder(this._context, this._apis, this.urlReplacer);

  Future<void> build() async {
    const apiMetaName = 'Api';
    for (var api in _apis) {
      var result = await _context.currentSession
              .getResolvedUnit(p.normalize(api.file.absolute.path))
          as ResolvedUnitResult;
      var apiClass = result.unit.declarations
          .whereType<ClassDeclaration>()
          .where((c) => c.metadata.any((m) => m.name.name == apiMetaName))
          .where((c) => api.className == null || c.name2.toString() == api.className)
          .single;

      var apiTag = _removeSuffix(apiClass.name2.toString(), suffix: 'Api');
      tags.add({'name': apiTag, 'description': api.description});

      var apiMeta =
          apiClass.metadata.firstWhere((m) => m.name.name == apiMetaName);
      var basePath =
          (apiMeta.arguments!.arguments.first as StringLiteral).stringValue!;
      var urlPrefix = api.urlPrefix;
      if (urlPrefix != null) {
        basePath = p.url.join(urlPrefix, basePath);
      }

      for (var method in apiClass.members.whereType<MethodDeclaration>()) {
        var methodElement = method.declaredElement2! as MethodElement;
        var meta = method.metadata.firstWhereOrNull((m) => const [
              'Get',
              'Post',
              'Put',
              'Patch',
              'Delete'
            ].contains(m.name.name));
        if (meta != null) {
          var methodPath = method.name2.toString().words.toLowerHyphen();
          if (meta.arguments!.arguments.isNotEmpty) {
            methodPath =
                (meta.arguments!.arguments.first as StringLiteral).stringValue!;
          }
          var httpMethod = meta.name.name.toLowerCase();

          var returnType = method.returnType?.type;
          Map<String, dynamic>? response;
          if (returnType != null && !isVoid(returnType)) {
            response = {
              'application/json': {
                'schema': _schemaForType(returnType),
              },
            };
          }

          var parameters = <Map<String, dynamic>>[];
          Object? requestBody;

          var fullUrl = p.url.join(basePath, methodPath);
          var urlReplacement = urlReplacer?.call(fullUrl);
          if (urlReplacement != null) {
            fullUrl = urlReplacement.url;
            var newParameters = urlReplacement.newParameters;
            if (newParameters != null) {
              for (var newParameter in newParameters.entries) {
                if (!methodElement.parameters
                    .any((e) => e.name == newParameter.key)) {
                  parameters.insert(0, {
                    'name': newParameter.key,
                    'in': 'path',
                    'required': true,
                    'schema': {'type': newParameter.value},
                  });
                }
              }
            }
          }

          bool isPathParameter(ParameterElement p) =>
              fullUrl.contains('{${p.name}}');
          var nonPathParameters =
              methodElement.parameters.whereNot(isPathParameter).toList();

          for (var parameter
              in methodElement.parameters.where(isPathParameter).toList()) {
            parameters.add({
              'name': parameter.name,
              'in': 'path',
              'required': true,
              'schema': _schemaForType(parameter.type),
            });
          }

          if (const ['get', 'delete'].contains(httpMethod)) {
            for (var parameter in nonPathParameters) {
              parameters.add({
                'name': parameter.name,
                'in': 'query',
                'required':
                    parameter.type.nullabilitySuffix == NullabilitySuffix.none,
                'schema': _schemaForType(parameter.type),
              });
            }
          } else {
            var requiredList = nonPathParameters
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
                      for (var parameter in nonPathParameters)
                        parameter.name: _schemaForType(parameter.type),
                    },
                  }
                }
              },
            };
          }

          var comment = _commentString(methodElement.documentationComment);
          var pathEntry = paths['/$fullUrl'] ??= {};
          pathEntry[httpMethod] = {
            'operationId': method.name2.toString(),
            'tags': [apiTag],
            if (comment != null) 'description': comment,
            if (parameters.isNotEmpty) 'parameters': parameters,
            if (requestBody != null) 'requestBody': requestBody,
            'responses': {
              '200': {
                'description': 'Success',
                if (response != null) 'content': response,
              },
              '500': {r'$ref': '#/components/responses/Error'},
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
      var element = type.element2!;
      if (element is ClassElement) {
        List<String>? enums;
        var comment = _commentString(element.documentationComment);

        if (element is EnumElement) {
          enums = element.fields
              .where((f) => f.isStatic && f.name != 'values')
              .map((e) => e.name)
              .toList();
        } else if (element.allSupertypes
            .any((s) => s.element2.name == 'EnumLike')) {
          enums = element.fields
              .where((f) => f.isConst && f.hasInitializer && f.name != 'values')
              .map((e) =>
                  e.computeConstantValue()?.getField('value')?.toStringValue())
              .whereNotNull()
              .toList();
        }

        if (enums != null) {
          schemas[typeName] = {
            if (comment != null) 'description': comment,
            'type': 'string',
            'enum': enums,
          };
        } else {
          var fields = element.fields.where((e) {
            // Filter getters only
            return !e.isStatic && e.nameOffset >= 0;
          });
          var required = fields
              .where((f) => f.type.nullabilitySuffix == NullabilitySuffix.none)
              .map((f) => f.name)
              .toList();

          var description = schemas[typeName] = {
            'type': 'object',
            if (comment != null) 'description': comment,
            if (required.isNotEmpty) 'required': required,
          };
          var properties = {};
          for (var field in fields) {
            var fieldComment = _commentString(field.documentationComment);
            var fieldSchema = _schemaForType(field.type);
            properties[field.name] = {
              // Description with $ref field is not supported in OpenApi 3.0.0
              // 3.1.0 does support it. But SwaggerUI doesn't support this version yet.
              if (fieldComment != null && !fieldSchema.containsKey(r'$ref'))
                'description': fieldComment,
              ...fieldSchema,
            };
          }
          description['properties'] = properties;
        }
      }
    }

    return '#/components/schemas/$typeName';
  }

  String? _commentString(String? comment) {
    if (comment != null) {
      return LineSplitter.split(comment)
          .map((l) => l.substring(3).trim())
          .join('\n');
    }
    return null;
  }

  String _removeSuffix(String input, {required String suffix}) {
    if (input.endsWith(suffix)) {
      return input.substring(0, input.length - suffix.length);
    }
    return input;
  }
}

class Api {
  final File file;
  final String? className;
  final String description;
  final String? urlPrefix;

  Api(
    String file, {
    this.className,
    required this.description,
    this.urlPrefix,
  }) : file = File(file);
}

class UrlReplacement {
  final String url;
  final Map<String, String>? newParameters;

  UrlReplacement(this.url, {this.newParameters});
}
