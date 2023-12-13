import 'package:flutter_core/datasources/local/database/dao/data_access_object.dart';
import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'di/di.dart';
import 'model/dummy_entity.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() {
    setupDatabaseDi();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'Should return false when `tableExists()` is called and the table isn`t created yet',
    () async {
      final dao = getIt.get<DataAccessObject>();

      final tableExists = await dao.tableExists(DummyTable.tableName);
      expect(tableExists, false);

      await getIt.get<DatabaseProvider>().close();
    },
  );

  test(
    'Should create table when try to insert an entity and the table does not exist yet',
    () async {
      final DataAccessObject dao = getIt.get();

      final tableExistsBeforeInsert = await dao.tableExists(
        DummyTable.tableName,
      );
      expect(tableExistsBeforeInsert, false);

      await dao.insert(entity: DummyEntity(null, "dummy_1"));
      final tableExistsAfterInsert = await dao.tableExists(
        DummyTable.tableName,
      );
      expect(tableExistsAfterInsert, true);

      await getIt.get<DatabaseProvider>().close();
    },
  );
}
