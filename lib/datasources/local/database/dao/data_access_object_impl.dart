import 'package:flutter_core/datasources/local/database/dao/data_access_object.dart';
import 'package:flutter_core/datasources/local/entity.dart';
import 'package:sqflite/sqflite.dart';

import '../provider/database_provider.dart';

class DataAccessObjectImpl implements DataAccessObject {
  final DatabaseProvider _provider;

  //https://pub.dev/packages/sqflite_common_ffi
  DataAccessObjectImpl(this._provider);
  
  Future<bool> tableExists(String tableName) async {
    bool tableExists = false;
    final db = await _provider.database;
    if (db == null) {
      return tableExists;
    }

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    tableExists = result.isNotEmpty;

    return tableExists;
  }

  @override
  Future insert({required Entity entity}) async {
    final db = await _provider.database;
    if (db == null || entity.table == null) {
      return;
    }
    await _insert(entity, db);

    await db.close();
  }

  @override
  Future insertAll({required List<Entity> entities}) async {
    final db = await _provider.database;
    if (db == null) {
      return;
    }

    for (var entity in entities) {
      await _insert(entity, db);
    }

    await db.close();
  }

  Future _insert(Entity entity, Database db) async {
    final String table = entity.table!;

    bool mTableExists = await tableExists(table);
    if (!mTableExists) {
      await db.execute(entity.createTable());
    }

    if (entity.table != null) {
      await db.insert(
        table,
        entity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<Entity> get<Entity>(int id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<Entity>?> getAll<Entity>({
    required String table,
    required Entity Function(Map<String, Object?>) fromMap,
  }) async {
    List<Entity>? entities;
    final db = await _provider.database;
    if (db == null) {
      return null;
    }

    bool mTableExists = await tableExists(table);
    if (!mTableExists) {
      return null;
    }

    final result = await db.query(table);
    entities = result.map(fromMap).toList();

    await db.close();

    return entities;
  }

  @override
  Future<bool> containsEntity({
    required Entity entity,
  }) async {
    final db = await _provider.database;

    if (entity.table == null) {
      throw ArgumentError("Entity table must not be null", "$entity");
    }

    final String table = entity.table!;

    if (db == null) return false;

    bool mTableExists = await tableExists(table);
    if (!mTableExists) return false;

    final entityMap = entity.toMap();
    String where = entityMap.keys.map((e) => "$e = ?").join(' AND ');

    final result = await db.query(table,
        where: where, whereArgs: entityMap.values.toList());

    await db.close();

    return result.isNotEmpty;
  }
}
