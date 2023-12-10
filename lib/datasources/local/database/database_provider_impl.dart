import 'package:flutter_core/datasources/local/database/database_provider.dart';
import 'package:flutter_core/datasources/local/entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProviderImpl implements DatabaseProvider {
  final String _dbName = '';

  @override
  Future<Database?> get database async {
    return await openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: 1,
    );
  }

  Future<bool> _tableExists(String tableName) async {
    bool tableExists = false;
    final db = await database;
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
    final db = await database;
    if (db == null || entity.table == null) {
      return;
    }
    await _insert(entity, db);

    await db.close();
  }

  @override
  Future insertAll({required List<Entity> entities}) async {
    final db = await database;
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

    bool tableExists = await _tableExists(table);
    if (!tableExists) {
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
    final db = await database;
    if (db == null) {
      return null;
    }

    bool tableExists = await _tableExists(table);
    if (!tableExists) {
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

    final db = await database;

    if(entity.table == null) throw ArgumentError("Entity table must not be null", "$entity");
    final String table = entity.table!;

    if (db == null) return false;

    bool tableExists = await _tableExists(table);
    if(!tableExists) return false;

    final entityMap = entity.toMap();
    String where = entityMap.keys.map((e) => "$e = ?").join(' AND ');

    final result = await db.query(table, where: where, whereArgs: entityMap.values.toList());

    await db.close();

    return result.isNotEmpty;
  }
}
