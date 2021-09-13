import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:server_utils/src/database/orm/schema.dart';

class SqlFile {
  final queries = <SqlQuery>[];
  final imports = <String>[];
}

class MethodDescription {
  final String name;
  final Result result;

  MethodDescription(this.name, this.result);

  @override
  bool operator ==(other) =>
      other is MethodDescription &&
      other.name == name &&
      other.result == result;

  @override
  int get hashCode => name.hashCode ^ result.hashCode;

  @override
  String toString() => 'MethodDescription(name: $name, result: $result)';
}

class Result {
  static final defaultValue = Result(null, ResultType.all);

  final String? name;
  final ResultType type;
  final bool isGenerated;

  Result(this.name, this.type, {this.isGenerated = false});

  @override
  String toString() =>
      'Result(name: $name, type: $type, isGenerated: $isGenerated)';

  @override
  bool operator ==(other) =>
      other is Result &&
      other.name == name &&
      other.type == type &&
      other.isGenerated == isGenerated;

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ isGenerated.hashCode;

  static final _pageOrListExtractor =
      RegExp(r'^([a-z]+)<([a-z0-9_.@]*)>$', caseSensitive: false);
  static final _simpleTypeExtractor =
      RegExp(r'^([a-z0-9_.@]*)([!?]?)$', caseSensitive: false);
  static Result parse(String line) {
    if (line.isEmpty) return defaultValue;

    var resultType = ResultType.all;

    late String rawName;
    var match = _pageOrListExtractor.firstMatch(line);
    if (match != null) {
      var container = match.group(1);
      rawName = match.group(2) ?? '';

      if (container == 'Page') {
        resultType = ResultType.page;
      } else if (container == 'List') {
        resultType = ResultType.list;
      } else {
        throw Exception('Unknown container $container');
      }
    } else {
      match = _simpleTypeExtractor.firstMatch(line);
      if (match == null) {
        throw Exception('Unrecognized result pattern: $line');
      }
      rawName = match.group(1)!;
      var mark = match.group(2);
      if (mark == '?') {
        resultType = ResultType.singleOrNull;
      } else if (mark == '!') {
        resultType = ResultType.single;
      }
    }

    String? name;
    var isGenerated = false;
    if (rawName.startsWith('@')) {
      isGenerated = true;
      name = rawName.substring(1);
      if (name.contains('.')) {
        throw Exception('Generated name cannot contains dots');
      }
    } else {
      name = rawName;
    }
    if (name.isEmpty) {
      name = null;
    }

    return Result(name, resultType, isGenerated: isGenerated);
  }
}

enum ResultType { all, single, singleOrNull, page, list }

class SqlQuery {
  final MethodDescription method;
  final String query;
  final List<Parameter> parameters;
  final columnOptions = <String, ColumnOptions>{};
  final ColumnOptions _defaultColumnOptions;

  SqlQuery({required this.method, required this.query})
      : parameters = extractParameters(query),
        _defaultColumnOptions = _extractDefaultColumnOptions(query) {
    var allHints = _columnHintsExtractors.allMatches(query);
    for (var match in allHints) {
      columnOptions[match.group(1)!] = ColumnOptions.parse(match.group(3)!);
    }
  }

  static final _columnHintsExtractors = RegExp(
      r'''["']?([a-zA-Z0-9_]+)(::[a-z0-9]+)?["']?\s*\/\*\s*(.*)\s*\*\/''');

  static final _parameterExtractor = RegExp(
      r'[^:]:([a-z][a-z0-9]*)(::([a-z][a-z0-9]+))?',
      caseSensitive: false);

  @visibleForTesting
  static List<Parameter> extractParameters(String sqlQuery) {
    var matches = _parameterExtractor.allMatches(sqlQuery);
    var parameters = <Parameter>[];
    for (var match in matches) {
      var name = match.group(1)!;
      var type = match.group(3);
      if (type == null) {
        throw Exception(
            'Parameters in queries must be typed (ie: :param::text). Error for $name in query:\n$sqlQuery');
      }
      parameters.add(Parameter(name, DataType.fromPostgresName(type)));
    }
    return parameters;
  }

  static final _defaultColumnsOptionExtractor =
      RegExp(r'^--\s*columns\s*:(.*)');
  static ColumnOptions _extractDefaultColumnOptions(String query) {
    for (var line in LineSplitter.split(query)) {
      var match = _defaultColumnsOptionExtractor.firstMatch(line);
      if (match != null) {
        var options = match.group(1)!;
        return ColumnOptions.parse(options);
      }
    }
    return ColumnOptions();
  }

  bool? isColumnNullable(String columnName) =>
      columnOptions[columnName]?.isNullable ?? _defaultColumnOptions.isNullable;

  @override
  String toString() => 'SqlQuery(${method.name})';
}

class Parameter {
  final String name;
  final DataType type;

  Parameter(this.name, this.type);
}

class ColumnOptions {
  final bool? isNullable;
  final String? defaultValue;

  ColumnOptions({this.isNullable, this.defaultValue});

  static ColumnOptions parse(String input) {
    bool? isNullable;
    String? defaultValue;

    for (var option in input.split(',')) {
      var keyValue = option.trim().split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1].trim();
        if (key == 'nullable') {
          isNullable = value.toLowerCase() == 'true';
        } else if (key == 'default') {
          defaultValue = value;
        }
      }
    }

    return ColumnOptions(isNullable: isNullable, defaultValue: defaultValue);
  }
}

class _SqlQueryBuilder {
  final MethodDescription method;
  final buffer = StringBuffer();

  _SqlQueryBuilder(this.method);

  SqlQuery toQuery() =>
      SqlQuery(method: method, query: buffer.toString().trim());
}

final _methodNameExtractor = RegExp(r'^[a-z][a-z0-9_$]*', caseSensitive: false);

SqlFile parseSqlFile(String fileContent) {
  var result = SqlFile();

  _SqlQueryBuilder? currentQuery;
  for (var line in LineSplitter.split(fileContent)) {
    if (line.startsWith('--#')) {
      if (currentQuery != null) {
        result.queries.add(currentQuery.toQuery());
        currentQuery = null;
      }
      var lineContent = line.substring(3).trim();
      if (lineContent.startsWith('import ')) {
        result.imports.add(lineContent);
      } else {
        var newMethod = parseMethod(lineContent);
        if (newMethod != null) {
          currentQuery = _SqlQueryBuilder(newMethod);
        } else {
          currentQuery = null;
        }
      }
    } else if (currentQuery != null) {
      currentQuery.buffer.writeln(line);
    }
  }
  if (currentQuery != null) {
    result.queries.add(currentQuery.toQuery());
  }

  return result;
}

@visibleForTesting
MethodDescription? parseMethod(String lineContent) {
  var methodNameMatch = _methodNameExtractor.firstMatch(lineContent);
  if (methodNameMatch != null) {
    var methodName = methodNameMatch.group(0)!;
    var result = Result.defaultValue;
    var split = lineContent.split('->');
    if (split.length > 1) {
      var resultContent = split[1].trim();
      result = Result.parse(resultContent);
    }
    return MethodDescription(methodName, result);
  } else {
    return null;
  }
}
