import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:path/path.dart' as p;
import 'package:analyzer/dart/analysis/utilities.dart';

Future<String> generateOpenApiSchema(File apiFile) async {
  var result = await resolveFile2(path: p.normalize(apiFile.absolute.path))
      as ResolvedUnitResult;

  var output = StringBuffer();

  // Steps:
  // - Api header (from parameters)
  // - Accept several File, with basePath associated
  // - Add filter/predicate callback
  // - Loop over all actions (with @Annotation)
  // - Collect all parameters and generate the parameter key
  // - Collect the output and generate the response
  // - Add all used ComplexType and output them at the end
  // - Fetch all ComplexType recursively for all fields (do it immediately when we add a ComplexType)
  //     and only do it once for each Type
  // - Loop over all fields and output the type
  // - Add the "required" field for non nullable field
  // - Add "enum" property for enum & enum-like class
  //     => enum like with only one "code", should be encoded as "string"
  // -

  return '';
}
