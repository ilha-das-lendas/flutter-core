import 'dart:async';

import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProviderImpl extends DatabaseProvider {
  final String _dbName;

  DatabaseProviderImpl(this._dbName);

  Future<String> get _path async => await getDatabasesPath();

  @override
  Future<String> get path => _path;

  @override
  Future<Database> get database async {
    return await openDatabase(
      join(await _path, _dbName),
      version: 1,
      onOpen: (database) async {
        const duration = Duration(seconds: 3);
        Future.delayed(duration, () {
          throw TimeoutException(
            "Database timout excpetion, it is open form more than 3 seconds",
            duration
          );
        });
      },
    );
  }

  Future<void> close() async => await (await database).close();
}
