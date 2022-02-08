import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'annotations.dart' show Api;
import 'error_handler.dart';
import 'exceptions.dart';

_RpcRouter createRpcRouter(Api apiInfo) => _RpcRouter(apiInfo);

class _RpcRouter {
  final Api apiInfo;
  final _router = Router();

  _RpcRouter(this.apiInfo);

  void get(String path, FutureOr Function(_RequestWrapper) callback) {
    _router.get(_path(path), _rpcHandler(path, callback));
  }

  void post(String path, FutureOr Function(_RequestWrapper) callback) {
    _router.post(_path(path), _rpcHandler(path, callback));
  }

  void delete(String path, FutureOr Function(_RequestWrapper) callback) {
    _router.delete(_path(path), _rpcHandler(path, callback));
  }

  String _path(String path) {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return path;
  }

  Handler _rpcHandler(
      String path, FutureOr Function(_RequestWrapper) callback) {
    return (request) async {
      try {
        var response = await callback(_RequestWrapper(request));

        return Response.ok(jsonEncode(response),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      } catch (e, stackTrace) {
        return rpcErrorHandler(apiInfo, request, e, stackTrace);
      }
    };
  }

  Handler get handler => _router;
}

class _RequestWrapper {
  final Request request;

  _RequestWrapper(this.request);

  _ParameterWrapper queryParameter(String parameterName) {
    return _ParameterWrapper(
        parameterName, request.requestedUri.queryParameters[parameterName]);
  }

  Future<Map<String, Object?>>? _body;
  Future<Map<String, Object?>> get body async => _body ??= _decodeBody();

  Future<Map<String, Object?>> _decodeBody() async {
    var body = await request.readAsString();
    if (body.isNotEmpty) {
      return jsonDecode(body) as Map<String, Object?>;
    } else {
      return {};
    }
  }
}

class _ParameterWrapper {
  final String parameterName;
  final String? _rawValue;

  _ParameterWrapper(this.parameterName, this._rawValue);

  T _ensureNotNull<T>(T? value) {
    if (value == null) {
      throw InvalidInputRpcException(
          "$parameterName with value $_rawValue can't be converted to type $T");
    }
    return value;
  }

  String requiredString() => _ensureNotNull(nullableString());
  String? nullableString() => _rawValue;

  int requiredInt() => _ensureNotNull(nullableInt());
  int? nullableInt() => int.tryParse(_rawValue ?? '');

  num requiredNum() => _ensureNotNull(nullableNum());
  num? nullableNum() => num.tryParse(_rawValue ?? '');

  double requiredDouble() => _ensureNotNull(nullableDouble());
  double? nullableDouble() => double.tryParse(_rawValue ?? '');

  bool requiredBool() => _ensureNotNull(nullableBool());
  bool? nullableBool() {
    var lower = _rawValue?.toLowerCase();

    bool? result;
    if (lower == 'true' || lower == '1') {
      result = true;
    } else if (lower != null) {
      result = false;
    }

    return result;
  }

  DateTime requiredDateTime() => _ensureNotNull(nullableDateTime());
  DateTime? nullableDateTime() => DateTime.tryParse(_rawValue ?? '');

  T requiredEnum<T>(List<T> enumsValues) =>
      _ensureNotNull(nullableEnum(enumsValues));
  T? nullableEnum<T>(List<T> enumsValues) =>
      enumsValues.firstWhereOrNull((e) => e.toString() == _rawValue);

  Object? _decodedJson;
  Object? get nullableJson {
    var rawValue = _rawValue;
    return rawValue == null ? null : (_decodedJson ??= jsonDecode(rawValue));
  }

  Object get requiredJson => _ensureNotNull(nullableJson);
}
