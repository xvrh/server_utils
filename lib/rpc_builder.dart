import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/rpc_builder/generator_client.dart';
import 'src/rpc_builder/generator_server.dart';

Builder rpcBuilder(BuilderOptions options) {
  return SharedPartBuilder([
    RpcRouterGenerator(),
  ], 'rpc_builder');
}

Builder rpcClientBuilder(BuilderOptions options) {
  return LibraryBuilder(RpcClientGenerator(),
      generatedExtension: '.g.client.dart');
}
