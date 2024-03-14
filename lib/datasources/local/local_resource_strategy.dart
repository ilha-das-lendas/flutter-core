import 'package:flutter_core/datasources/resource_strategy.dart';

class LocalDatasource<Result, Raw>
    extends ResourceStrategy<Result, Raw> {
  Future<Raw?> Function()? get;

  LocalDatasource.build({
    required super.mapper,
    this.get,
  }) : super.build();
}