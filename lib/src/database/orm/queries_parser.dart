import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'queries_decorators.dart' show Col;
import 'utils/sql_parser.dart';

QueriesFile parseQueries(String content) {
  var parseResult = parseString(content: content);
  var ast = parseResult.unit;

  var extensions = <QueriesExtension>[];

  for (var extension in ast.declarations
      .whereType<ExtensionDeclaration>()
      .where((e) => (e.extendedType as NamedType).name.name == 'Database')) {
    var name = extension.name?.name;
    if (name == null) continue;

    var queries = <QueryDeclaration>[];
    for (var method in extension.members.whereType<MethodDeclaration>()) {
      var returnType = method.returnType! as NamedType;
      var parameters = method.parameters!;
      var info = MethodInfo(
        _typeToString(returnType),
        method.name.name,
        DartParameters(parameters.toSource(),
            parameters.parameters.map(_parameterFromAst).toList()),
      );

      var body = method.body;
      SqlQuery? sqlQuery;
      ProjectionDeclaration? projection;
      TestValuesDeclaration? testValues;
      if (body is BlockFunctionBody) {
        for (var statement in body.block.statements) {
          Expression? expression;
          if (statement is ReturnStatement) {
            expression = statement.expression;
          } else if (statement is ExpressionStatement) {
            expression = statement.expression;
          }
          if (expression is MethodInvocation) {
            sqlQuery = _sqlQueryFromExpression(expression);
          } else if (expression is AssignmentExpression) {
            var left = expression.leftHandSide;
            if (left is SimpleIdentifier && left.name == 'projection') {
              projection = _projectionFromExpression(expression.rightHandSide);
            } else if (left is SimpleIdentifier && left.name == 'testValues') {
              testValues = _testValuesFromExpression(expression.rightHandSide);
            }
          }
        }
      } else if (body is ExpressionFunctionBody) {
        sqlQuery = _sqlQueryFromExpression(body.expression);
      }

      if (sqlQuery == null) {
        throw Exception('[${method.name}]: No SQL query found (q(...) method)');
      }

      var header = QueryHeader(info, projection, testValues);
      queries.add(QueryDeclaration(header, sqlQuery));
    }

    extensions.add(QueriesExtension(name, queries));
  }

  return QueriesFile(extensions);
}

DartParameter _parameterFromAst(FormalParameter parameter) {
  if (parameter is SimpleFormalParameter) {
    var type = parameter.type! as NamedType;
    return DartParameter(parameter.identifier!.name, _typeToString(type));
  } else if (parameter is DefaultFormalParameter) {
    return _parameterFromAst(parameter.parameter);
  } else {
    throw UnsupportedError(
        'Unknown parameter of type ${parameter.runtimeType}');
  }
}

SqlQuery? _sqlQueryFromExpression(Expression expression) {
  if (expression is MethodInvocation) {
    if (expression.methodName.name == 'q' &&
        expression.argumentList.arguments.length == 1) {
      var rawSql = expression.argumentList.arguments.first as StringLiteral;
      return SqlQuery.parse(rawSql.stringValue!);
    }
  }
  return null;
}

String _typeToString(NamedType type) {
  var simpleName = type.name.name;
  var typeArguments = type.typeArguments?.arguments;
  var question = type.question != null ? '?' : '';
  if (typeArguments != null && typeArguments.isNotEmpty) {
    return '$simpleName<${typeArguments.map((t) => (t as NamedType).name.name).join(', ')}>$question';
  } else {
    return '$simpleName$question';
  }
}

ProjectionDeclaration _projectionFromExpression(Expression expression) {
  Expression? arg(String name, InvocationExpression invocation) {
    return invocation.argumentList.arguments
        .whereType<NamedExpression>()
        .firstWhereOrNull((e) => e.name.label.name == name)
        ?.expression;
  }

  bool? boolArg(Expression? expression) {
    if (expression == null) return null;
    return (expression as BooleanLiteral).value;
  }

  var projectionLines = <ProjectionLine>[];
  var right = expression as SetOrMapLiteral;
  for (var entry in right.elements.cast<MapLiteralEntry>()) {
    var key = entry.key as StringLiteral;
    var value = entry.value as InvocationExpression;

    projectionLines.add(
      ProjectionLine(
        key.stringValue!,
        Col(
          nullable: boolArg(arg('nullable', value)),
        ),
      ),
    );
  }
  return ProjectionDeclaration(projectionLines);
}

TestValuesDeclaration _testValuesFromExpression(Expression expression) {
  var lines = <TestValueLine>[];
  var set = expression as SetOrMapLiteral;
  for (var entry in set.elements.cast<AssignmentExpression>()) {
    var key = entry.leftHandSide as SimpleIdentifier;
    var valueExpression = entry.rightHandSide;
    dynamic value;
    if (valueExpression is StringLiteral) {
      value = valueExpression.stringValue;
    } else if (valueExpression is BooleanLiteral) {
      value = valueExpression.value;
    } else if (valueExpression is IntegerLiteral) {
      value = valueExpression.value;
    } else if (valueExpression is DoubleLiteral) {
      value = valueExpression.value;
    }

    lines.add(TestValueLine(key.name, value));
  }

  return TestValuesDeclaration(lines);
}

class QueriesFile {
  final List<QueriesExtension> extensions;

  QueriesFile(this.extensions);

  @override
  String toString() => 'QueriesFile($extensions)';
}

class QueriesExtension {
  final String name;
  final List<QueryDeclaration> queries;

  QueriesExtension(this.name, this.queries);

  @override
  String toString() => 'QueriesExtension($name, $queries)';
}

class QueryDeclaration {
  final QueryHeader header;
  final SqlQuery query;

  QueryDeclaration(this.header, this.query);

  @override
  String toString() => 'QueryDeclaration($header, $query)';
}

class QueryHeader {
  final MethodInfo method;
  final ProjectionDeclaration? projection;
  final TestValuesDeclaration? testValues;

  QueryHeader(this.method, this.projection, this.testValues);

  @override
  String toString() => 'QueryHeader($method, $projection)';
}

class MethodInfo {
  final String returnType;
  final String name;
  final DartParameters parameters;

  MethodInfo(this.returnType, this.name, this.parameters);

  @override
  String toString() => 'MethodInfo($returnType, $name, $parameters)';
}

class DartParameters {
  final String rawDeclaration;
  final List<DartParameter> parameters;

  DartParameters(this.rawDeclaration, this.parameters);

  @override
  String toString() => 'DartParameters($rawDeclaration)';
}

class DartParameter {
  final String name;
  final String type;

  DartParameter(this.name, this.type);

  @override
  bool operator ==(other) =>
      other is DartParameter && other.name == name && other.type == type;

  @override
  int get hashCode => Object.hash(name, type);

  @override
  String toString() => 'DartParameter($name, $type)';
}

class ProjectionDeclaration {
  final List<ProjectionLine> lines;

  ProjectionDeclaration(this.lines);

  ProjectionLine? get defaultLine =>
      lines.firstWhereOrNull((e) => e.columnName == '*');

  ProjectionLine? lineFor(String columnName) =>
      lines.firstWhereOrNull((e) => e.columnName == columnName);

  @override
  String toString() => 'ProjectionDeclaration(lines: $lines)';
}

class ProjectionLine {
  final String columnName;
  final Col config;

  ProjectionLine(this.columnName, this.config);

  bool? get nullable => config.nullable;

  @override
  String toString() => 'ProjectionLine($columnName, $config)';
}

class TestValuesDeclaration {
  final List<TestValueLine> values;

  TestValuesDeclaration(this.values);
}

class TestValueLine {
  final String name;
  final dynamic value;

  TestValueLine(this.name, this.value);
}
