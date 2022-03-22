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
  const Post([String? path]) : super(path);
}

class Put extends Action {
  const Put([String? path]) : super(path);
}

class Patch extends Action {
  const Patch([String? path]) : super(path);
}

class Get extends Action {
  const Get([String? path]) : super(path);
}

class Delete extends Action {
  const Delete([String? path]) : super(path);
}

class Action {
  final String? path;

  const Action(this.path);
}
