import 'package:json_annotation/json_annotation.dart';
import 'package:server_utils/rpc.dart';

part 'api.g.dart';

@Api('page')
class PageApi {
  @Get()
  Future<Entity> fetchEntity() async {
    throw UnimplementedError();
  }
}

@JsonSerializable()
class Entity {
  /// Some comment that should also be visible
  final OneEnum myEnum;

  /// This one can have a description
  final num otherProp;

  Entity({required this.myEnum, required this.otherProp});

  factory Entity.fromJson(Map<String, dynamic> json) => _$EntityFromJson(json);

  Map<String, dynamic> toJson() => _$EntityToJson(this);
}

/// Come other comment
/// On several lines
/// Just like this
enum OneEnum { value1, value2 }
