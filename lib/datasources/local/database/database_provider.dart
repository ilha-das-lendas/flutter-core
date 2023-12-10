import 'package:flutter_core/datasources/local/entity.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseProvider {
  Future<Database?> get database;

  Future insert({required Entity entity});

  Future<Entity?> get<Entity>(int id);

  Future<List<Entity>?> getAll<Entity>({
    required String table,
    required Entity Function(Map<String, Object?>) fromMap,
  });

  Future insertAll({required List<Entity> entities});

  Future<bool> containsEntity({required Entity entity});
}
