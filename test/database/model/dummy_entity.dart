import 'package:flutter_core/datasources/local/entity.dart';

import '../../model/dummy_model.dart';

class DummyEntity extends Entity {
  @override
  get table => DummyTable.tableName;

  final int? _id;

  @override
  int? get id => _id;

  final String self;

  DummyEntity(this._id, this.self);

  @override
  String createTable() => DummyTable.createTable;

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DummyTable.columnId: id,
      DummyTable.columnSelf: self,
    };
    return map;
  }

  factory DummyEntity.fromMap(Map<String, dynamic> map) {
    return DummyEntity(
      map[DummyTable.columnId] as int?,
      map[DummyTable.columnSelf] as String,
    );
  }
}

extension DummyEntityExtension on DummyEntity {
  DummyModel toModel() => DummyModel(id, self);
}

class DummyTable {
  static const tableName = "Dummy";
  static const columnId = "id";
  static const columnSelf = "self";
  static const createTable = '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSelf TEXT
      )
    ''';
}
