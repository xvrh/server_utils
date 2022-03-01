import 'package:petitparser/petitparser.dart';

class SqlGrammarDefinition extends GrammarDefinition {
  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim(ref0(hiddenStuff));
    } else if (input is String) {
      return token(input.toParser());
    }
    throw ArgumentError.value(input, 'Invalid token parser');
  }

  @override
  Parser<SqlQuery> start() => ref0(query).end().cast<SqlQuery>();

  Parser query() => (ref0(queryBody) & ref1(token, ';').optional()).map((l) {
        return l[0];
      });

  Parser queryBody() => (ref0(innerQuery).star()).token().map((l) {
        return SqlQuery(
            l.input.trimRight(), l.value.whereType<SqlParameter>().toList(),
            position: l.start);
      });

  Parser innerQuery() =>
      ref0(sqlParameter).trim(ref0(hiddenStuff)) |
      ref0(multiLineString) |
      ref0(singleLineString).trim(ref0(hiddenStuff)) |
      ref0(sqlParameterType) |
      ref0(identifier) |
      ref1(token, anyOf(r'=:(){}[]|&?!,-/+~*.<>')) |
      ref1(token, pattern('0-9'));

  Parser singleLineString() =>
      char('"') & ref0(stringContentDoubleQuoted).star() & char('"') |
      char("'") & ref0(stringContentSingleQuoted).star() & char("'");

  Parser multiLineString() {
    return ref0(multiLineStringDelimiter) &
        ref0(multiLineStringDelimiter).neg().star() &
        ref0(multiLineStringDelimiter).trim(ref0(hiddenStuff));
  }

  Parser multiLineStringDelimiter() =>
      (char(r'$') & char(r'$').neg().star() & char(r'$')).flatten();

  Parser stringContentDoubleQuoted() => anyOf('"\n\r').neg();

  Parser stringContentSingleQuoted() => anyOf("'\n\r").neg();

  Parser sqlParameter() => (anyOf(':@').token() &
          ref0(identifierLexicalToken) &
          ref0(sqlParameterType).optional())
      .map((s) => SqlParameter(s[0] as Token<String>, s[1] as Token<String>,
          s[2] as Token<String>?));

  Parser sqlParameterType() =>
      (string(':') & string(':').optional() & ref0(sqlParameterTypeToken))
          .map((s) => s.last);

  Parser sqlParameterTypeToken() =>
      (ref0(identifierLexicalToken) & string('[]').optional())
          .flatten()
          .token();

  Parser identifier() => ref1(token, ref0(identifierLexicalToken));

  Parser identifierLexicalToken() => (ref0(identifierStartLexicalToken) &
          ref0(identifierPartLexicalToken).star())
      .flatten()
      .token();

  Parser identifierPartLexicalToken() => ref0(letter) | ref0(digit) | char('_');
  Parser identifierStartLexicalToken() => ref0(letter) | char('_');

  Parser newlineLexicalToken() => pattern('\n\r');

  Parser hiddenStuff() =>
      ref0(whitespace) | ref0(singleLineComment) | ref0(multiLineComment);

  Parser singleLineComment() =>
      string('--') &
      ref0(newlineLexicalToken).neg().star() &
      ref0(newlineLexicalToken).optional();

  Parser multiLineComment() =>
      string('/*').seq(string('*').not()) &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string('*/');
}

class SqlQuery {
  final int position;
  final String body;
  final List<SqlParameter> parameters;

  SqlQuery(this.body, this.parameters, {required this.position});

  @override
  String toString() => 'SqlQuery($body, parameters: $parameters)';

  String get bodyWithDartSubstitutions {
    var output = StringBuffer();
    var lastSliceStart = 0;
    for (var parameter in parameters) {
      if (lastSliceStart != parameter._colonToken.start - position) {
        output.write(body.substring(
            lastSliceStart, parameter._colonToken.start - position));
      }
      output.write('@');
      lastSliceStart = parameter._colonToken.stop - position;
    }
    if (lastSliceStart != body.length) {
      output.write(body.substring(lastSliceStart));
    }
    return '$output';
  }

  static SqlQuery parse(String content) {
    final definition = SqlGrammarDefinition();
    final parser = definition.build();
    var result = parser.parse(content).map((e) => e as SqlQuery);
    if (result.isFailure) {
      throw SqlQueryParseException(
          'Fail to parse SQL: ${result.message} (${result.toPositionString()}).\nQuery: [$content]');
    }
    return result.value;
  }
}

class SqlQueryParseException implements Exception {
  final String message;

  SqlQueryParseException(this.message);

  @override
  String toString() => 'SqlQueryParseException($message)';
}

class SqlParameter {
  final Token<String> _colonToken;
  final Token<String> _nameToken;
  final Token<String>? _typeToken;

  SqlParameter(this._colonToken, this._nameToken, this._typeToken);

  String get name => _nameToken.value;

  String? get type => _typeToken?.value;

  @override
  String toString() => 'SqlParameter(name: $name, type: $type)';
}
