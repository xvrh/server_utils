import 'package:shelf/shelf.dart' show Handler;

class Api<T> {
  final String path;
  final String name;
  final Handler Function(T)? factory;

  const Api(this.path)
      : name = '',
        factory = null;

  Api.info({required this.path, required this.name, required this.factory});

  Handler handler(T api) {
    return factory!(api);
  }
}

class Post extends Action {
  const Post();
}

class Get extends Action {
  const Get();
}

class Delete extends Action {
  const Delete();
}

class Action {
  const Action();
}
