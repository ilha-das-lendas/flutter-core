import 'package:flutter_core/datasources/resource_strategy.dart';
import 'package:flutter_core/datasources/local/entity.dart';

class LocalResourceStrategy<T> extends ResourceStrategy<T, dynamic> {
  LocalResourceStrategy.handler({
    Future<List<Entity>> Function()? query,
    T Function(dynamic)? mapQueryResult,
  }) : super.build(fetch: query, mapper: mapQueryResult);
}
