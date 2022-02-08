import 'dart:convert';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:path/path.dart' as p;

final _featureSet = FeatureSet.fromEnableFlags2(
    sdkLanguageVersion: Version(2, 15, 0), flags: []);

String fixCodeStyle(String content,
    {required String packageName, required String libPath}) {
  var newContent = content;

  var unit = parseString(content: content, featureSet: _featureSet).unit;

  for (var directive
      in unit.directives.reversed.whereType<NamespaceDirective>()) {
    var uriValue = directive.uri.stringValue!;
    var absolutePrefix = 'package:$packageName/';
    if (uriValue.startsWith(absolutePrefix)) {
      var absoluteImportFromLib = uriValue.replaceAll(absolutePrefix, '');
      var relativePath = p
          .relative(absoluteImportFromLib, from: p.dirname(libPath))
          .replaceAll(r'\', '/');

      var directiveContent =
          directive.uri.toString().replaceAll(uriValue, relativePath);

      newContent = newContent.replaceRange(directive.uri.offset,
          directive.uri.offset + directive.uri.length, directiveContent);
    }
  }

  newContent = _reorderImports(newContent);

  return newContent;
}

String _reorderImports(String content) {
  var unit = parseString(content: content, featureSet: _featureSet).unit;

  var wholeDirectives = <_WholeDirective>[];
  var imports = <ImportDirective>[];
  var exports = <ExportDirective>[];
  var parts = <PartDirective>[];

  var minOffset = 0, maxOffset = 0;
  var lastOffset = 0;
  var isFirst = true;
  for (var directive in unit.directives) {
    if (directive is UriBasedDirective) {
      int offset, length;
      if (isFirst) {
        isFirst = false;

        var token = directive.metadata.beginToken ??
            directive.firstTokenAfterCommentAndMetadata;

        offset = token.offset;
        length =
            (directive.endToken.offset + directive.endToken.length) - offset;
        minOffset = offset;
        maxOffset = length + offset;
      } else {
        offset = lastOffset;
        length =
            directive.endToken.offset + directive.endToken.length - lastOffset;
      }

      maxOffset = offset + length;
      lastOffset = maxOffset;

      var wholeDirective = _WholeDirective(directive, offset, length);
      wholeDirectives.add(wholeDirective);

      if (directive is ImportDirective) {
        imports.add(directive);
      } else if (directive is ExportDirective) {
        exports.add(directive);
      } else {
        parts.add(directive as PartDirective);
      }
    }
  }

  imports.sort(_compare);
  exports.sort(_compare);
  parts.sort(_compare);

  var contentBefore = content.substring(0, minOffset);
  var reorderedContent = '';

  String _writeBlock(List<UriBasedDirective> directives) {
    var result = '';
    for (var directive in directives) {
      var wholeDirective = wholeDirectives.firstWhere(
          (wholeDirective) => wholeDirective.directive == directive);
      var directiveString = content.substring(wholeDirective.countedOffset,
          wholeDirective.countedOffset + wholeDirective.countedLength);

      var normalizedDirective = directive.toString().replaceAll('"', "'");
      directiveString =
          directiveString.replaceAll(directive.toString(), normalizedDirective);

      result += directiveString;
    }
    return '$result\n\n';
  }

  reorderedContent += _removeBlankLines(_writeBlock(imports));
  reorderedContent += _removeBlankLines(_writeBlock(exports));
  reorderedContent += _removeBlankLines(_writeBlock(parts));

  var contentAfter = content.substring(maxOffset);

  var newContent = contentBefore + reorderedContent + contentAfter;
  return newContent;
}

String _removeBlankLines(String content) {
  var lines = LineSplitter.split(content).toList();
  var result = <String>[];
  var i = 0;
  for (var line in lines) {
    if (i == 0 || line.trim().isNotEmpty) {
      result.add(line);
    }
    ++i;
  }

  return '\n${result.join('\n')}';
}

int _compare(UriBasedDirective directive1, UriBasedDirective directive2) {
  var uri1 = directive1.uri.stringValue!;
  var uri2 = directive2.uri.stringValue!;

  if (uri1.contains(':') && !uri2.contains(':')) {
    return -1;
  } else if (!uri1.contains(':') && uri2.contains(':')) {
    return 1;
  } else {
    return uri1.compareTo(uri2);
  }
}

class _WholeDirective {
  final UriBasedDirective directive;
  final int countedOffset;
  final int countedLength;

  _WholeDirective(this.directive, this.countedOffset, this.countedLength);
}
