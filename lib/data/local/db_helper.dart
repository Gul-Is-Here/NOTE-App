import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  /// Thats a sinalton class
  DBHelper._();
  static final DBHelper dbHelper = DBHelper._();
  static final String table_note = "note";
  static final String column_note_sr_no = "s_no";
  static final String column_note_title = "title";
  static final String column_note_desc = "desc";

  /// it can handle null able
  Database? myDatabase;

  /// dbOpen (path -> if exists then open else create db)
  Future<Database> getDB() async {
    return myDatabase ??= await openDB();
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    return await openDatabase(dbPath, onCreate: (db, version) {
      db.execute(
          "create table $table_note( $column_note_sr_no integer primary key autoincrement, $column_note_title text, $column_note_desc)");
    }, version: 1);
  }

  /// ALl Queries

  /// Insetion
  Future<bool> addNote(
      {required String noteTitle, required String noteDesc}) async {
    var db = await getDB();
    int rowsAffected = await db.insert(table_note, {
      column_note_title: noteTitle,
      column_note_desc: noteDesc,
    });
    return rowsAffected > 0;
  }

  // Get all data from Database
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(table_note);
    return mData;
  }
}
