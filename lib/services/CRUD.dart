import 'package:my_daily_to_do/services/database.dart';
import 'package:sqflite/sqflite.dart';

import '../model/todo.dart';

class Crud {
  Future<Todo> insertTodo(Todo todo) async {
    final db = await MyDatabase.connect();
    await db.insert(
      "todos",
      todo.toMap(),
      ConflictAlgorithm.replace
    );
  }


  
}
