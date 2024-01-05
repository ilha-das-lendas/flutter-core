import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseProviderImplTest implements DatabaseProvider {
  @override
  Future<Database> get database async => _database;

  @override
  Future<String> get path async => inMemoryDatabasePath;

  @override
  Future<void> close() async => {
    'the :memory: database should be closed only when the test finish'
  };

  Future<Database> get _database async => await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
      );
}
