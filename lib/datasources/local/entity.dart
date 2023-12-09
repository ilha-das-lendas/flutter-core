abstract class Entity {
  int? id;
  String? table;

  String createTable();

  Map<String, dynamic> toMap();
}