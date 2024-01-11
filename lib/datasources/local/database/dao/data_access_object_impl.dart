import 'package:flutter/foundation.dart';
import 'package:flutter_core/datasources/local/database/dao/data_access_object.dart';
import 'package:flutter_core/datasources/local/entity.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../provider/database_provider.dart';

class DataAccessObjectImpl implements DataAccessObject {
  final DatabaseProvider _provider;

  Future<Database> get _database async => await _provider.database;

  DataAccessObjectImpl(this._provider);

  @visibleForTesting
  @override
  Future<bool> tableExists(Database database, String tableName) async {
    final database = await _database;
    List<Map<String, dynamic>> tables = await database.query('sqlite_master');

    return tables.any((table) => table['name'] == tableName);
  }

  @override
  Future<int> insert<T extends Entity>({required T entity}) async {
    final database = await _database;

    final id = await _insert(database, entity);

    return id;
  }

  @override
  Future insertAll<T extends Entity>({required List<T> entities}) async {
    final database = await _database;

    for (var entity in entities) {
      await _insert(database, entity);
    }
  }

  Future<int> _insert(Database database, Entity entity) async {
    bool mTableExists = await tableExists(database, entity.table);
    if (!mTableExists) {
      await database.execute(entity.createTable());
    }

    return await database.insert(
      entity.table,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<T?> get<T extends Entity>(
    int id, {
    required T Function(Map<String, Object?>) toEntity,
    required String table,
  }) async {
    final database = await _database;

    final result = await database.rawQuery(
      'SELECT * FROM $table WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;
    return toEntity.call(result.first);
  }

  @override
  Future<List<T>?> getAll<T extends Entity>({
    required String table,
    required T Function(Map<String, Object?>) fromMap,
  }) async {
    List<T>? entities;
    final database = await _database;

    bool mTableExists = await tableExists(database, table);
    if (!mTableExists) {
      return null;
    }

    final result = await database.query(table);
    entities = result.map(fromMap).toList();

    return entities;
  }

  @override
  Future<bool> containsEntity<T extends Entity>({
    required T entity,
  }) async {
    final database = await _database;

    bool mTableExists = await tableExists(database, entity.table);
    if (!mTableExists) return false;

    final entityMap = entity.toMap();
    String whereCondition = entityMap.keys.map((e) => "$e = ?").join(' AND ');

    final result = await database.query(
      entity.table,
      where: whereCondition,
      whereArgs: entityMap.values.toList(),
    );

    return result.isNotEmpty;
  }

  @override
  Future<int> deleteWithArgs({
    required String table,
    required Map<String, dynamic> args,
  }) async {
    final database = await _database;
    String whereCondition = args.keys.map((e) => "$e = ?").join(' AND ');
    List<dynamic> whereValues = args.values.map((e) => e).toList();

    return await database.rawDelete(
      'DELETE FROM $table where $whereCondition',
      whereValues,
    );
  }

  @override
  Future<int> delete<T extends Entity>(T? entity) async {
    final database = await _database;
    final result = await _delete(database, entity?.table, entity?.id);
    return result;
  }

  @override
  Future<int> deleteWithId({required String table, required int? id}) async {
    final database = await _database;
    final result = await _delete(database, table, id);
    return result;
  }

  Future<int> _delete(Database database, String? table, int? id) async {
    return await database.rawDelete(
      'DELETE FROM $table WHERE id = ?',
      [id],
    );
  }
}
