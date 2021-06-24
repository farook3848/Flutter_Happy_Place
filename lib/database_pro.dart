// @dart=2.9
import 'package:learning_flutter/modelclass.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'modelclass.dart';

class DatabaseProvider {
  static final DatabaseProvider db = DatabaseProvider._init();
  static Database _database;
  DatabaseProvider._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    return await openDatabase(join(await getDatabasesPath(), "databasesee.db"),
        onCreate: (db, version) async {
      await db.execute(''' 
      CREATE TABLE datasetttt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        location TEXT,
        images BLOB,
        creation_date DATE

      )
 ''');
    }, version: 1);
  }

  addNewNote(PlaceModel note) async {
    final db = await database;
    db.insert("datasetttt", note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<dynamic> getNotes() async {
    final db = await database;
    var res = await db.query("datasetttt");
    if (res.length == 0) {
      return Null;
    } else {
      var resultMap = res.toList();
      return resultMap.isNotEmpty ? resultMap : Null;
    }
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    int count = await db.rawDelete("DELETE FROM datasetttt WHERE id = ?", [id]);
    return count;
  }

  Future<int> updateNote(int id, String title, String body, String location,
      String images, DateTime date) async {
    final db = await database;
    int count = await db.rawUpdate('''
    UPDATE datasetttt   
    SET title = ?, body = ?, location = ? ,images = ?,creation_date = ? 
    WHERE id = ?
    ''', [title, body, location, images, date.toString().substring(0, 10), id]);
    return count;
  }
}
