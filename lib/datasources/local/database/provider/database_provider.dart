import 'package:sqflite/sqflite.dart';

abstract class DatabaseProvider {
  Future<Database> get database;
  Future<String> get path;
}