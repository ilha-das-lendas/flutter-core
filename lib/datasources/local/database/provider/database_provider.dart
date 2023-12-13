import 'package:sqflite/sqflite.dart';

abstract class DatabaseProvider {
  Future<Database?> get database;
  Future<void> close();
  Future<String> get path;
}