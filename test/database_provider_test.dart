import 'package:flutter_core/datasources/local/database/dao/data_access_object_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_provider_impl_test.dart';
import 'model/dummy_entity.dart';

void main() {
  sqfliteFfiInit();

  test(
    'Should return false when `tableExists()` is called and the table isn`t created yet',
    () async {
      final dbProvider = DataAccessObjectImpl(DatabaseProviderImplTest());

      final tableExists = await dbProvider.tableExists(DummyTable.tableName);
      expect(tableExists, false);
    },
  );
}
