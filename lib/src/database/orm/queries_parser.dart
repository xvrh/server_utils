import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';
import 'utils/dart_parser.dart';
import 'utils/sql_parser.dart';

Result<QueriesFile> parseQueries(String content) {
  final definition = QueriesGrammarDefinition();
  final parser = definition.build();
  return parser.parse(content).map((e) => e as QueriesFile);
}

class QueriesGrammarDefinition extends GrammarDefinition {
  final Parser _dartMethodParser = (() {
    var dartDefinition = DartAstDefinition();
    return dartDefinition.build(start: dartDefinition.functionDeclaration);
  })();

  final Parser _dartLiteralParser = (() {
    var dartDefinition = DartLiteralDefinition();
    return dartDefinition.build(start: dartDefinition.valueLiteral);
  })();

  final Parser _sqlParser = (() {
    var sqlDefinition = SqlGrammarDefinition();
    return sqlDefinition.build(start: sqlDefinition.query);
  })();

  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim(ref0(hiddenStuff));
    } else if (input is String) {
      return token(input.toParser());
    }
    throw ArgumentError.value(input, 'Invalid token parser');
  }

  Parser directivePrefix() => ref1(token, '--@');

  @override
  Parser start() => ref0(file).end();

  Parser file() => (ref0(directive).star().trim(ref0(hiddenStuff)) &
              ref0(query).star().trim(ref0(hiddenStuff)))
          .map((l) {
        return QueriesFile((l[0] as List).cast<Directive>(),
            (l[1] as List).cast<QueryDeclaration>());
      });

  Parser directive() =>
      ref0(extensionDirective) | ref0(classDirective) | ref0(importDirective);

  Parser extensionDirective() => (ref0(directivePrefix) &
          ref1(token, 'extension') &
          ref0(identifier).optional())
      .map((List s) => ExtensionDirective(s[2] as Identifier?));

  Parser classDirective() => (ref0(directivePrefix) &
          ref1(token, 'class') &
          ref0(identifier).optional())
      .map((List s) => ClassDirective(s[2] as Identifier?));

  Parser importDirective() => (ref0(directivePrefix) &
          ref1(token, 'import') &
          ref1(token, ';').neg().star().flatten().map(ImportDirective.new) &
          ref1(token, ';'))
      .map((s) => s[2]);

  Parser query() => (ref0(queryHeader).trim() & ref0(queryBody))
      .map((List s) => QueryDeclaration(s[0] as QueryHeader, s[1] as SqlQuery));

  Parser queryHeader() => (ref0(openQueryHeader).flatten() &
          ref0(queryHeaderBody) &
          (ref0(closeQueryHeader).flatten()))
      .map((s) => s[1]);

  Parser openQueryHeader() =>
      string('/**') & string('*').star() & ref0(newlineLexicalToken);

  Parser closeQueryHeader() =>
      string('**') & string('*').star() & char('/') & ref0(newlineLexicalToken);

  Parser queryHeaderBody() => (ref0(queryMethodSignature) &
              ref0(testValuesDeclaration).optional() &
              ref0(projectionDeclaration).optional())
          .map((s) {
        var projection = s.whereType<ProjectionDeclaration>().firstOrNull;
        var testValues = s.whereType<TestValuesDeclaration>().firstOrNull;
        return QueryHeader(s[0] as MethodDeclaration, projection, testValues);
      });

  Parser queryMethodSignature() => _dartMethodParser;

  Parser testValuesDeclaration() => (string('testValues') &
              ref1(token, '=') &
              ((ref1(token, '{') & ref1(token, '}')) |
                  (ref1(token, '{') &
                      ref0(testValueLine) &
                      ref0(testValueLineTail).optional() &
                      ref1(token, ',').optional() &
                      ref1(token, '}'))))
          .map((l) {
        var lines = (l[2] as List)
            .map((t) => t is TestValueLine ? t : t)
            .expand((f) => f is List ? f : [f])
            .whereType<TestValueLine>()
            .toList();
        return TestValuesDeclaration(lines);
      });

  Parser testValueLineTail() => (ref1(token, ',') &
              ref0(testValueLine) &
              ref0(testValueLineTail).optional())
          .map((l) {
        var first = l[1] as TestValueLine;
        var subList = l[2] as List<TestValueLine>?;
        return [first, ...?subList];
      });

  Parser testValueLine() => (ref0(identifier) &
              ref1(token, ':') &
              _dartLiteralParser.trim().map((s) => (s as Token).value))
          .map((s) {
        return TestValueLine(s[0] as Identifier, s[2]);
      });

  Parser projectionDeclaration() => (string('projection') &
              ref0(identifier) &
              ((ref1(token, '(') & ref1(token, ')')) |
                  (ref1(token, '(') &
                      ref0(projectionLine) &
                      ref0(projectionLineTail).optional() &
                      ref1(token, ',').optional() &
                      ref1(token, ')'))))
          .map((l) {
        var lines = (l[2] as List)
            .map((t) => t is ProjectionLine ? t : t)
            .expand((f) => f is List ? f : [f])
            .whereType<ProjectionLine>()
            .toList();
        return ProjectionDeclaration(l[1] as Identifier, lines);
      });

  Parser projectionLineTail() => (ref1(token, ',') &
              ref0(projectionLine) &
              ref0(projectionLineTail).optional())
          .map((l) {
        var first = l[1] as ProjectionLine;
        var subList = l[2] as List<ProjectionLine>?;
        return [first, ...?subList];
      });

  Parser projectionLine() =>
      ((ref1(token, '*') | ref0(identifier)) & ref0(projectionModifier).plus())
          .map((s) {
        var first = s[0];
        Identifier? name;
        if (first is Identifier) {
          name = first;
        }

        return ProjectionLine(name, (s[1] as List).cast<ProjectionModifier>());
      });

  Parser projectionModifier() =>
      ref0(notNullModifier) | ref0(nullModifier) | ref0(asModifier);

  Parser nullModifier() =>
      ref1(token, 'null').map((_) => ProjectionModifierNull());

  Parser notNullModifier() => (ref1(token, 'not') & ref1(token, 'null'))
      .map((_) => ProjectionModifierNotNull());

  Parser asModifier() => (ref1(token, 'as') & ref0(identifier))
      .map((s) => ProjectionModifierAs(s[1] as Identifier));

  Parser queryBody() => _sqlParser;

  Parser identifier() => ref1(token, ref0(identifierLexicalToken))
      .map((s) => (s as Token).value as Identifier);

  Parser identifierLexicalToken() =>
      (ref0(letter) & ref0(identifierPartLexicalToken).star())
          .flatten()
          .token()
          .map((token) => Identifier(token));

  Parser identifierPartLexicalToken() => ref0(letter) | ref0(digit) | char('_');

  Parser newlineLexicalToken() => pattern('\n\r');

  Parser hiddenStuff() =>
      ref0(whitespace) |
      ref0(singleLineComment) |
      ref0(multiLineCommentTopLevel);

  Parser singleLineComment() =>
      string('--').seq(char('@').not()) &
      ref0(newlineLexicalToken).neg().star() &
      ref0(newlineLexicalToken).optional();

  Parser multiLineCommentTopLevel() =>
      string('/*').seq(string('*').not()) &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string('*/');

  Parser multiLineComment() =>
      string('/*') &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string('*/');
}

class DartAstDefinition extends DartGrammarDefinition {
  @override
  Parser<MethodDeclaration> functionDeclaration() =>
      (ref0(returnType).flatten().trim() &
              ref0(identifier).flatten().trim() &
              ref0(formalParameterList).token().trim())
          .map((l) {
        var parametersToken = l[2] as Token;

        var dartParameters =
            _flatten(parametersToken.value).whereType<DartParameter>().toList();

        return MethodDeclaration(
            (l[0] as String).trim(),
            (l[1] as String).trim(),
            DartParameters(parametersToken.input, dartParameters));
      });

  @override
  Parser simpleFormalParameter() => super.simpleFormalParameter().map((l) {
        var list = l as List;
        return DartParameter(
            (list[1] as String).trim(), (list[0] as String).trim());
      });

  static Iterable<Object?> _flatten(Object? parent) sync* {
    if (parent is Token) {
      yield* _flatten(parent.value);
    } else if (parent is Iterable) {
      for (var child in parent) {
        yield* _flatten(child);
      }
    } else {
      yield parent;
    }
  }
}

class DartLiteralDefinition extends DartGrammarDefinition {
  Parser valueLiteral() => ref1(
      token,
      ref0(nullToken).map((s) => null) |
          ref0(trueToken).map((s) => true) |
          ref0(falseToken).map((s) => false) |
          ref0(hexNumberLexicalToken).flatten().map((s) => int.parse(s)) |
          ref0(numberLexicalToken).flatten().map((s) => num.parse(s)) |
          ref0(stringLexicalToken)
              .flatten()
              .map((s) => s.substring(1, s.length - 1)));
}

class QueriesFile {
  final List<Directive> directives;
  final List<QueryDeclaration> queries;

  QueriesFile(this.directives, this.queries);

  ExtensionDirective? get extensionDirective =>
      directives.whereType<ExtensionDirective>().firstOrNull;

  ClassDirective? get classDirective =>
      directives.whereType<ClassDirective>().firstOrNull;

  Iterable<ImportDirective> get importDirectives =>
      directives.whereType<ImportDirective>();

  @override
  String toString() => 'QueriesFile($directives, $queries)';
}

abstract class Directive {}

class ExtensionDirective implements Directive {
  final Identifier? name;

  ExtensionDirective(this.name);

  @override
  String toString() => 'ExtensionDirective($name)';
}

class ClassDirective implements Directive {
  final Identifier? name;

  ClassDirective(this.name);

  @override
  String toString() => 'ClassDirective($name)';
}

class ImportDirective implements Directive {
  final String body;

  ImportDirective(this.body);

  @override
  String toString() => 'ImportDirective($body)';
}

class QueryDeclaration {
  final QueryHeader header;
  final SqlQuery query;

  QueryDeclaration(this.header, this.query);

  @override
  String toString() => 'QueryDeclaration($header, $query)';
}

class QueryHeader {
  final MethodDeclaration method;
  final ProjectionDeclaration? projection;
  final TestValuesDeclaration? testValues;

  QueryHeader(this.method, this.projection, this.testValues);

  @override
  String toString() => 'QueryHeader($method, $projection)';
}

class MethodDeclaration {
  final String returnType;
  final String name;
  final DartParameters parameters;

  MethodDeclaration(this.returnType, this.name, this.parameters);

  @override
  String toString() => 'MethodDeclaration($returnType, $name, $parameters)';
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
  final Identifier name;
  final List<ProjectionLine> lines;

  ProjectionDeclaration(this.name, this.lines);

  ProjectionLine? get defaultLine =>
      lines.firstWhereOrNull((e) => e.columnName == null);

  ProjectionLine? lineFor(String columnName) =>
      lines.firstWhereOrNull((e) => e.columnName?.name == columnName);

  @override
  String toString() => 'ProjectionDeclaration($name, lines: $lines)';
}

class ProjectionLine {
  final Identifier? columnName;
  final List<ProjectionModifier> modifiers;

  ProjectionLine(this.columnName, this.modifiers);

  bool? get nullable {
    if (modifiers.any((e) => e is ProjectionModifierNull)) {
      return true;
    } else if (modifiers.any((e) => e is ProjectionModifierNotNull)) {
      return false;
    }
    return null;
  }

  @override
  String toString() => 'ProjectionLine($columnName, $modifiers)';
}

abstract class ProjectionModifier {}

class ProjectionModifierNull implements ProjectionModifier {
  @override
  String toString() => 'ProjectionModifierNull';
}

class ProjectionModifierNotNull implements ProjectionModifier {
  @override
  String toString() => 'ProjectionModifierNotNull';
}

class ProjectionModifierAs implements ProjectionModifier {
  final Identifier type;

  ProjectionModifierAs(this.type);

  @override
  String toString() => 'ProjectionModifierAs($type)';
}

class TestValuesDeclaration {
  final List<TestValueLine> values;

  TestValuesDeclaration(this.values);
}

class TestValueLine {
  final Identifier name;
  final dynamic value;

  TestValueLine(this.name, this.value);
}

class Identifier {
  final Token<String> token;

  Identifier(this.token);

  String get name => token.value;

  @override
  String toString() => name;
}
