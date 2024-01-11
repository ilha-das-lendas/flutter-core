import 'dart:async';
import 'dart:math';

import 'package:flutter_core/datasources/local/database/dao/data_access_object.dart';
import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_provider_impl_test.dart';
import 'di/di.dart';
import 'model/dummy_entity.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() {
    setupDatabaseDi();
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
    }, (error, stack) {
      expect(
        error.toString(),
        "TimeoutException after 0:00:03.000000: Database timout excpetion, it is open form more than 3 seconds",
      );
    });
  });

  test(
    'Should return false when `tableExists()` is called and the table isn`t created yet',
    () async {
      final dao = getIt.get<DataAccessObject>();
      final database = await getIt.get<DatabaseProvider>().database;

      final tableExists = await dao.tableExists(database, DummyTable.tableName);
      expect(tableExists, false);
    },
  );

  test(
    'Should return the deletion result when an entity is deleted by id',
    () async {
      final DataAccessObject dao = getIt.get();
      final insertionResultId = await dao.insert(
        entity: DummyEntity(null, "dummy_1"),
      );
      // expect(insertionResultId, 1);

      final deletionResultCount = await dao.deleteWithId(
        table: DummyTable.tableName,
        id: insertionResultId,
      );
      expect(deletionResultCount, 1);
    },
  );

  test(
    'Should return null when call `getAll` and has no data to map in the database',
    () async {
      final DataAccessObject dao = getIt.get();

      final result = await dao.getAll<DummyEntity>(
        table: DummyTable.tableName,
        fromMap: DummyEntity.fromMap,
      );

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
        fromMap: DummyEntity.fromMap,
      );

      expect(result, isEmpty);
    },
  );
}
