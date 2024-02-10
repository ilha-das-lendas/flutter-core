abstract class Entity {
  int? get id;
  String get table;

  String createTable();

  Map<String, dynamic> toMap();
}