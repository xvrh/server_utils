import 'dart:collection';
import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

part 'page.g.dart';

@JsonSerializable()
class Page<TEntities>
    with IterableMixin<TEntities>
    implements Iterable<TEntities> {
  @JsonKey(ignore: true)
  final List<TEntities> entities = [];

  final int totalLength;
  final PageRequest pageRequest;

  Page({required this.totalLength, required this.pageRequest});

  factory Page.fromJson(Map<String, dynamic> json,
          {required TEntities Function(dynamic) entitiesReviver}) =>
      _$PageFromJson<TEntities>(json)
        ..entities.addAll((json['entities'] as List).map(entitiesReviver));

  Map<String, dynamic> toJson() => _$PageToJson(this)..['entities'] = entities;

  @override
  int get length => entities.length;

  int get pageSize => pageRequest.pageSize;

  int get pageCount => (totalLength / pageRequest.pageSize).ceil();

  int get offset => pageRequest.offset;

  bool get hasNextPage =>
      pageRequest.offset + pageRequest.pageSize < totalLength;

  bool get hasPreviousPage => pageRequest.pageIndex > 0;

  PageRequest get nextPageRequest =>
      hasNextPage ? pageRequest.next : pageRequest;

  PageRequest get previousPageRequest =>
      hasPreviousPage ? pageRequest.previous : pageRequest;

  PageRequest get firstPageRequest => PageRequest(
      pageIndex: 0, pageSize: pageRequest.pageSize, sort: pageRequest.sort);

  PageRequest get lastPageRequest => PageRequest(
      pageIndex: pageCount - 1,
      pageSize: pageRequest.pageSize,
      sort: pageRequest.sort);

  @override
  String toString() => 'Page(totalLength: $totalLength, '
      'pageRequest: $pageRequest, '
      'entities: ${entities.length})';

  @override
  Iterator<TEntities> get iterator => entities.iterator;
}

@JsonSerializable()
class PageRequest {
  final int pageSize;
  final int pageIndex;
  final Sort sort;

  PageRequest({int? pageIndex, int? pageSize, required this.sort})
      : pageIndex = pageIndex ?? 0,
        pageSize = pageSize ?? 10 {
    assert(this.pageIndex >= 0);
  }

  factory PageRequest.fromJson(Map<String, dynamic> json) =>
      _$PageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PageRequestToJson(this);

  int get offset => pageIndex * pageSize;

  PageRequest get next => PageRequest(pageIndex: pageIndex + 1, sort: sort);

  PageRequest get previous =>
      PageRequest(pageIndex: max(pageIndex - 1, 0), sort: sort);

  @override
  bool operator ==(other) =>
      other is PageRequest &&
      other.pageSize == pageSize &&
      other.pageIndex == pageIndex &&
      other.sort == sort;

  @override
  int get hashCode => pageIndex ^ pageSize ^ sort.hashCode;

  @override
  String toString() =>
      'PageRequest(pageIndex: $pageIndex, pageSize: $pageSize, sort: $sort)';
}

@JsonSerializable()
class Sort {
  final String field;
  final SortDirection direction;

  Sort(this.field, {SortDirection? direction})
      : direction = direction ?? SortDirection.asc;

  factory Sort.desc(String field) => Sort(field, direction: SortDirection.desc);

  factory Sort.fromJson(Map<String, dynamic> json) => _$SortFromJson(json);

  Map<String, dynamic> toJson() => _$SortToJson(this);

  @override
  bool operator ==(other) =>
      other is Sort && other.field == field && other.direction == direction;

  @override
  int get hashCode => field.hashCode ^ direction.hashCode;

  @override
  String toString() => '$field ${sortDirectionToString(direction)}';
}

enum SortDirection { asc, desc }

String sortDirectionToString(SortDirection direction) =>
    direction == SortDirection.asc ? 'asc' : 'desc';
