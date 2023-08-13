import 'dart:convert';

class MapBackup {
  MapBackup(this.source) {
    update();
  }

  final Map source;

  String backupJson = "";

  update() {
    backupJson = jsonEncode(source).toString();
  }

  restore() {
    source.clear();

    Map temp = jsonDecode(backupJson);

    for (MapEntry<dynamic, dynamic> entry in temp.entries) {
      source[entry.key] = entry.value;
    }
  }
}