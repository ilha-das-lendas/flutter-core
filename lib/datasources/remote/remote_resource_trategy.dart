import 'package:flutter_core/datasources/resource_strategy.dart';

class RemoteDataSource<Result, Raw>
    extends ResourceStrategy<Result, Raw> {
  Future<Raw>? Function()? fetch;

  RemoteDataSource.build({
    required super.mapper,
    this.fetch,
  }) : super.build();
}