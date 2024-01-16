import 'dart:async';

import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseProviderImplTest implements DatabaseProvider {
  @override
  Future<Database> get database async => _database;

  @override
  Future<String> get path async => inMemoryDatabasePath;

  @override
  Future<void> close() async => (await _database).close();

  Future<Database> get _database async => await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          onOpen: (database) async {
            const duration = Duration(seconds: 3);
            Future.delayed(duration, () async {
              throw TimeoutException(
                "Database timout excpetion, it is open from more than 3 seconds",
                duration,
              );
            });
          },
        ),
      );
}
