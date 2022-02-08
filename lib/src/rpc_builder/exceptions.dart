import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exceptions.g.dart';

class KnownException<T extends RpcException> {
  final String name;
  final T Function(Map<String, Object?>) fromJson;

  KnownException(this.name, {required this.fromJson});

  bool matches(RpcException e) => e is T;
}

/// Exception thrown on the Server that can be serialized on the wire and will
/// be rethrown on the client
@JsonSerializable()
class RpcException implements Exception {
  final int status;
  final String message;
  final Map<String, Object?> data;

  RpcException(this.status, this.message, {Map<String, Object?>? data})
      : data = data ?? {};

  factory RpcException.fromJson(Map<String, dynamic> json) =>
      _$RpcExceptionFromJson(json);

  Map<String, dynamic> toJson() => _$RpcExceptionToJson(this);

  @override
  String toString() => '$status: $message';

  static final knownExceptions = <KnownException>{
    KnownException<NotFoundRpcException>('NotFoundRpcException',
        fromJson: NotFoundRpcException.fromJson),
    KnownException<InvalidInputRpcException>('InvalidInputRpcException',
        fromJson: InvalidInputRpcException.fromJson),
  };

  static RpcException deserialize(String? typeName, Map<String, Object?> json) {
    if (typeName != null) {
      var known = knownExceptions.firstWhereOrNull((e) => e.name == typeName);
      if (known != null) {
        return known.fromJson(json);
      }
    }
    return RpcException.fromJson(json);
  }

  static String? nameFor(RpcException exception) =>
      knownExceptions.firstWhereOrNull((e) => e.matches(exception))?.name;
}

/// Thrown when resource does not exist.
@JsonSerializable()
class NotFoundRpcException extends RpcException {
  NotFoundRpcException(String message) : super(404, message);
  NotFoundRpcException.resource(String resource)
      : super(404, 'Could not find `$resource`.');

  static NotFoundRpcException fromJson(Map<String, dynamic> json) =>
      _$NotFoundRpcExceptionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NotFoundRpcExceptionToJson(this);
}

/// Thrown when request input is invalid, bad payload, wrong querystring, etc.
@JsonSerializable()
class InvalidInputRpcException extends RpcException {
  InvalidInputRpcException(String message) : super(400, message);

  static InvalidInputRpcException fromJson(Map<String, dynamic> json) =>
      _$InvalidInputRpcExceptionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InvalidInputRpcExceptionToJson(this);

  /// Check [condition] and throw [InvalidInputException] with [message] if
  /// [condition] is `false`.
  static void check(bool condition, String message) {
    if (!condition) {
      throw InvalidInputRpcException(message);
    }
  }

  /// A variant of [check] with lazy message construction.
  static void _check(bool condition, String Function() message) {
    if (!condition) {
      throw InvalidInputRpcException(message());
    }
  }

  /// Throw [InvalidInputException] if [value] doesn't match [regExp].
  static void checkMatchPattern(String value, String name, RegExp regExp) {
    _check(regExp.hasMatch(value), () => '"$name" must match $regExp');
  }

  /// Throw [InvalidInputException] if [value] is not one of [values].
  static void checkAnyOf<T>(T value, String name, Iterable<T>? values) {
    _check(values!.contains(value),
        () => '"$name" must be any of ${values.join(', ')}');
  }

  /// Throw [InvalidInputException] if [value] is less than [minimum] or greater
  /// than [maximum].
  static void checkRange<T extends num>(
    T? value,
    String name, {
    T? minimum,
    T? maximum,
  }) {
    _check(value != null, () => '"$name" cannot be `null`');
    _check(minimum == null || value! >= minimum,
        () => '"$name" must be greater than $minimum');
    _check(maximum == null || value! <= maximum,
        () => '"$name" must be less than $maximum');
  }

  /// Throw [InvalidInputException] if [value] is shorter than [minimum] or
  /// longer than [maximum].
  ///
  /// This also throws if [value] is `null`.
  static void checkStringLength(
    String? value,
    String name, {
    int? minimum,
    int? maximum,
  }) {
    _check(value != null, () => '"$name" cannot be `null`');
    _check(minimum == null || value!.length >= minimum,
        () => '"$name" must be longer than $minimum characters');
    _check(maximum == null || value!.length <= maximum,
        () => '"$name" must be less than $maximum characters');
  }

  /// Throw [InvalidInputException] if [value] is shorter than [minimum] or
  /// longer than [maximum].
  static void checkLength<T>(
    Iterable<T>? value,
    String name, {
    int? minimum,
    int? maximum,
  }) {
    _check(value != null, () => '"$name" cannot be `null`');
    final length = value!.length;
    _check(minimum == null || length >= minimum,
        () => '"$name" must be longer than $minimum');
    _check(maximum == null || length <= maximum,
        () => '"$name" must be less than $maximum');
  }
}
