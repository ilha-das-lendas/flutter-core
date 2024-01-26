import 'dart:async';

import 'package:flutter_core/datasources/local/database/dao/data_access_object.dart';
import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'di/di.dart';
import 'model/dummy_entity.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() {
    setupDatabase();
    databaseFactory = databaseFactoryFfi;
  });

  test('Database should not be open for more than 3', () async {
    await runZonedGuarded(() async {
      final database = await getIt.get<DatabaseProvider>().database;
      await Future.delayed(const Duration(seconds: 4));
      await database.rawQuery(DummyTable.createTable);
      await database.insert(
        DummyTable.tableName,
        DummyEntity(null, "dummy_1").toMap(),
      );
      await database.close();
    }, (error, stack) {
      expect(
        error.toString(),
        "TimeoutException after 0:00:03.000000: Database timout excpetion, it is open from more than 3 seconds",
      );
    });
  });

  test(
    'Should return false when `tableExists()` is called and the table isn`t created yet',
    () async {
      final dao = getIt.get<DataAccessObject>();
      final database = await getIt.get<DatabaseProvider>().database;

      final tableExists = await dao.tableExists(database, DummyTable.tableName);
      await dao.close();

      expect(tableExists, false);
    },
  );

  test(
    'Should return the inserted object id when insert with success',
    () async {
      final DataAccessObject dao = getIt.get();
      final insertionResultId = await dao.insert(
        entity: DummyEntity(null, "dummy_1"),
      );

      expect(insertionResultId, 1);

      await dao.deleteWithId(
        table: DummyTable.tableName,
        id: insertionResultId,
      );

      await dao.close();
    },
  );

  test(
    'Should return the deletion result when an entity is deleted by id',
    () async {
      final DataAccessObject dao = getIt.get();
      final insertionResultId = await dao.insert(
        entity: DummyEntity(null, "dummy_1"),
      );

      final deletionResultCount = await dao.deleteWithId(
        table: DummyTable.tableName,
        id: insertionResultId,
      );

      await dao.close();

      expect(deletionResultCount, 1);
    },
  );

  test(
    'Should return null when call `getAll` and has no data to map in the database',
    () async {
      final DataAccessObject dao = getIt.get();

      final result = await dao.getAll<DummyEntity>(
        table: DummyTable.tableName,
        toEntity: DummyEntity.fromMap,
      );

      await dao.close();

      expect(result, isNull);
    },
  );

  test(
    'Should return empty list when call `getAll`, the table exists but has no data',
    () async {
      final database = await getIt.get<DatabaseProvider>().database;
      final DataAccessObject dao = getIt.get();

      await database.execute(DummyTable.createTable);

      final result = await dao.getAll<DummyEntity>(
        table: DummyTable.tableName,
        toEntity: DummyEntity.fromMap,
      );

      await dao.close();
      expect(result, isEmpty);
    },
  );

  test(
    'Should return a list with items when call `getAll`, the table exists and has data',
    () async {
      final DataAccessObject dao = getIt.get();

      await dao.insert(
        entity: DummyEntity(null, "dummy_1"),
      );

      final result = await dao.getAll<DummyEntity>(
        table: DummyTable.tableName,
        toEntity: DummyEntity.fromMap,
      );

      await dao.close();
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    },
  );

  test(
    'Should return the inserted id list when insert more than one entity at time',
    () async {
      final DataAccessObject dao = getIt.get();

      List<DummyEntity> dummies = [
        DummyEntity(null, "dummy_1"),
        DummyEntity(null, "dummy_2"),
        DummyEntity(null, "dummy_3"),
      ];

      final result = await dao.insertAll(entities: dummies);

      await dao.close();
      expect(result, isNotEmpty);
    },
  );

  test(
    'Should return null when the entity does not exists',
    () async {
      final DataAccessObject dao = getIt.get();

      final result = await dao.get(
        1,
        table: DummyTable.tableName,
        toEntity: DummyEntity.fromMap,
      );

      await dao.close();
      expect(result, isNull);
    },
  );

  test(
    'Should return the entity when the database has value',
    () async {
      final DataAccessObject dao = getIt.get();

      final id = await dao.insert(entity: DummyEntity(null, 'dummy_1'));
      final result = await dao.get(
        id,
        table: DummyTable.tableName,
        toEntity: DummyEntity.fromMap,
      );

      await dao.close();
      expect(result, isNotNull);
      expect(result?.self, equals('dummy_1'));
    },
  );

  test(
    'Should return true when the database contains the entity',
    () async {
      final DataAccessObject dao = getIt.get();

      final entity = DummyEntity(1, 'dummy_1');
      await dao.insert(entity: entity);
      final containsEntity = await dao.containsEntity(entity: entity);

      expect(containsEntity, true);

      await dao.delete(entity);
      await dao.close();
    },
  );

  test(
    'Should return false when does not contain the entity',
    () async {
      final DataAccessObject dao = getIt.get();

      await dao.insert(entity: DummyEntity(null, 'dummy_1'));
      final containsEntity = await dao.containsEntity(
        entity: DummyEntity(2, 'dummy_1'),
      );

      expect(containsEntity, false);

      await dao.deleteWithId(id: 1, table: DummyTable.tableName);
      await dao.close();
    },
  );

  test(
    'Should find and delete a specific entity that matches with the args passed as arguments',
    () async {
      final DataAccessObject dao = getIt.get();

      await dao.insert(entity: DummyEntity(null, 'dummy_1'));

      final deletedEntitiesQuantity = await dao.deleteWithArgs(
        table: DummyTable.tableName,
        args: {
          DummyTable.columnSelf: 'dummy_1',
        },
      );

      await dao.close();

      expect(deletedEntitiesQuantity, 1);
    },
  );
}
