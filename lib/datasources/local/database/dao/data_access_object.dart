import 'package:flutter_core/datasources/local/entity.dart';

abstract class DataAccessObject {
  Future insert({required Entity entity});

  Future<Entity?> get<Entity>(int id);

  Future<List<Entity>?> getAll<Entity>({
    required String table,
    required Entity Function(Map<String, Object?>) fromMap,
  });

  Future insertAll({required List<Entity> entities});

  Future<bool> containsEntity({required Entity entity});

  Future<bool> tableExists(String tableName);
}
