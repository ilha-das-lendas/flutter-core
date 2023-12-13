import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProviderImpl extends DatabaseProvider {
  final String _dbName;

  DatabaseProviderImpl(this._dbName);

  Future<String> get _path async => await getDatabasesPath();

  @override
  Future<String> get path => _path;

  @override
  Future<Database?> get database async {
    return await openDatabase(
      join(await _path, _dbName),
      version: 1,
    );
  }

  @override
  Future<void> close() async => (await database)?.close();
}
