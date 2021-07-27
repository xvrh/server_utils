import 'dart:convert';
import 'package:meta/meta.dart';

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
        throw Exception('Unrecognized result pattern.');
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

  SqlQuery({required this.method, required this.query});

  @override
  String toString() => 'SqlQuery(${method.name})';
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
