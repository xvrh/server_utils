import 'dart:collection';
import 'dart:math';

class Page<TEntities>
    with IterableMixin<TEntities>
    implements Iterable<TEntities> {
  final List<TEntities> entities;
  final int totalLength;
  final PageRequest<TEntities> pageRequest;

  Page({
    required this.totalLength,
    required this.pageRequest,
    required this.entities,
  });

  factory Page.fromJson(Map<String, dynamic> json,
          {required TEntities Function(dynamic) entitiesReviver}) =>
      Page<TEntities>(
        totalLength: json['totalLength'] as int,
        pageRequest: PageRequest<TEntities>.fromJson(
          json['pageRequest'] as Map<String, dynamic>,
          tableReviver: entitiesReviver,
        ),
        entities: (json['entities'] as List).map(entitiesReviver).toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalLength': totalLength,
        'pageRequest': pageRequest.toJson(),
        'entities': entities,
      };

  @override
  int get length => entities.length;

  int get pageSize => pageRequest.pageSize;

  int get pageCount => (totalLength / pageRequest.pageSize).ceil();

  int get index => pageRequest.pageIndex;

  int get offset => pageRequest.offset;

  bool get hasNextPage =>
      pageRequest.offset + pageRequest.pageSize < totalLength;

  bool get hasPreviousPage => index > 0;

  PageRequest<TEntities> get nextPage =>
      hasNextPage ? pageRequest.next : pageRequest;

  PageRequest<TEntities> get previousPage =>
      hasPreviousPage ? pageRequest.previous : pageRequest;

  PageRequest<TEntities> get firstPage => pageRequest.first;

  PageRequest<TEntities> get lastPage =>
      pageRequest.copyWith(pageIndex: pageCount - 1);

  @override
  String toString() => 'Page(totalLength: $totalLength, '
      'pageRequest: $pageRequest, '
      'entities: ${entities.length})';

  @override
  Iterator<TEntities> get iterator => entities.iterator;
}

class PageRequest<TTable> {
  final int pageIndex;
  final int pageSize;
  final Column<TTable> sort;
  final bool sortAscending;

  PageRequest(
      {int? pageIndex, int? pageSize, required this.sort, bool? sortAscending})
      : pageIndex = pageIndex ?? 0,
        pageSize = pageSize ?? 10,
        sortAscending = sortAscending ?? true {
    assert(this.pageIndex >= 0);
  }

  factory PageRequest.fromJson(Map<String, dynamic> json,
      {required TTable Function(Map?) tableReviver}) {
    return PageRequest<TTable>(
      pageIndex: json['pageIndex'] as int?,
      pageSize: json['pageSize'] as int?,
      sort: Column<TTable>(json['sort']! as String),
      sortAscending: json['sortAscending'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'sort': sort.name,
        'sortAscending': sortAscending,
      };

  int get offset => pageIndex * pageSize;

  PageRequest<TTable> get next => copyWith(pageIndex: pageIndex + 1);

  PageRequest<TTable> get previous =>
      copyWith(pageIndex: max(pageIndex - 1, 0));

  PageRequest<TTable> get first => copyWith(
      pageIndex: 0,
      pageSize: pageSize,
      sort: sort,
      sortAscending: sortAscending);

  PageRequest<TTable> copyWith(
      {int? pageIndex,
      int? pageSize,
      Column<TTable>? sort,
      bool? sortAscending}) {
    return PageRequest(
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
      sort: sort ?? this.sort,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  bool operator ==(other) =>
      other is PageRequest &&
      other.pageIndex == pageIndex &&
      other.pageSize == pageSize &&
      other.sort.name == sort.name &&
      other.sortAscending == sortAscending;

  @override
  int get hashCode =>
      Object.hash(pageIndex, pageSize, sort.name, sortAscending);

  @override
  String toString() =>
      'PageRequest(pageIndex: $pageIndex, pageSize: $pageSize, sort: $sort)';
}

extension PageRequestExtension<T> on PageRequest<T>? {
  PageRequest<T> withDefaults(
      {required int pageSize,
      int? maxPageSize,
      required Column<T> sort,
      bool? sortAscending}) {
    maxPageSize ??= 1000;
    return PageRequest(
      pageSize: this?.pageSize.clamp(1, maxPageSize) ?? pageSize,
      pageIndex: this?.pageIndex,
      sort: this?.sort ?? sort,
      sortAscending: this?.sortAscending ?? sortAscending,
    );
  }
}

class Column<TEntity> {
  final String name;

  Column(this.name);

  @override
  bool operator ==(other) => other is Column<TEntity> && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Column<$TEntity>($name)';
}
