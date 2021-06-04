import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Control {

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/data.json");
  }

  static Future<File> saveData(List todoList) async {
    String content = json.encode(todoList);
    final file = await _getFile();

    return file.writeAsString(content);
  }

 static Future<String> readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}