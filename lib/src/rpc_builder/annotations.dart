import 'package:shelf/shelf.dart' show Handler;

class Api<T> {
  final String path;
  final String name;
  final Handler Function(T)? factory;

  const Api(this.path)
      : name = '',
        factory = null;

  const Api.info(
      {required this.path, required this.name, required this.factory});

  Handler handler(T api) {
    return factory!(api);
  }
}

class Post extends Action {
  final String? path;

  const Post([this.path]);
}

class Put extends Action {
  final String? path;

  const Put([this.path]);
}

class Patch extends Action {
  final String? path;

  const Patch([this.path]);
}

class Get extends Action {
  final String? path;

  const Get([this.path]);
}

class Delete extends Action {
  final String? path;

  const Delete([this.path]);
}

class Action {
  const Action();
}
