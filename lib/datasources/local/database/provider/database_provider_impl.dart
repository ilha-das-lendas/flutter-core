import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProviderImpl extends DatabaseProvider {
  final String _dbName;

  DatabaseProviderImpl(this._dbName);

  @override
  Future<Database?> get database async {
    return await openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: 1,
    );
  }
}
