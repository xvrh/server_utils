// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RpcClientGenerator
// **************************************************************************

// GENERATED-CODE: do not edit
// This code is generated by the rpc_builder tool

import 'dart:convert';
import 'package:http/http.dart';
import 'package:path/path.dart' as path_helper;
import 'package:server_utils/rpc_client.dart';
import 'api.dart' show Entity;

export 'api.dart' show Entity;

// ignore_for_file: implementation_imports

class PageClient {
  final Client _client;
  final String _basePath;

  PageClient(this._client, {required String basePath}) : _basePath = basePath;

  void close() => _client.close();

  Future<Entity> fetchEntity() async {
    var $url =
        Uri.parse(path_helper.url.join(_basePath, 'page', 'fetch-entity'));
    var $response = await _client.get($url);
    checkResponseSuccess($url, $response);
    var $decodedResponse = jsonDecode($response.body);
    return Entity.fromJson($decodedResponse! as Map<String, Object?>);
  }
}