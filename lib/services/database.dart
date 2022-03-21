import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyDatabase {
  static connect() async {
    final database = openDatabase(join(await getDatabasesPath(), "todo.db"),
        onCreate: ((db, version) {
      return db.execute("CREATE TABLE todos (" +
          "id integer not null primary key auto_increment," +
          "name TEXT not null, " +
          "status boolean not null default false)");
    }), version: 1);
    return database;
  }
}

