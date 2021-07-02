import 'package:shelf/shelf.dart' show Handler;

class Controller<T> {
  final String path;
  final String? name;
  final Handler Function(T)? factory;

  const Controller(this.path)
      : name = null,
        factory = null;

  Controller.info(
      {required this.path, required this.name, required this.factory});

  Handler handler(T controller) {
    return factory!(controller);
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
