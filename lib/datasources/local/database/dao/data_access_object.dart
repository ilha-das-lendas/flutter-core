import 'package:flutter_core/datasources/local/entity.dart';
import 'package:sqflite/sqflite.dart';

abstract class DataAccessObject {
  Future<int> insert<T extends Entity>({required T entity});

  Future<int> delete<T extends Entity>(T? entity);

  Future<int> deleteWithArgs({
    required String table,
    required Map<String, dynamic> args,
  });

  Future<int> deleteWithId({required String table, required int? id});

  Future<T?> get<T extends Entity>(
    int id, {
    required String table,
    required T Function(Map<String, Object?>) toEntity,
  });

  Future<List<T>?> getAll<T extends Entity>({
    required String table,
    required T Function(Map<String, Object?>) fromMap,
  });

  Future insertAll<T extends Entity>({required List<T> entities});

  Future<bool> containsEntity<T extends Entity>({required T entity});

  Future<bool> tableExists(Database database, String tableName);
}
