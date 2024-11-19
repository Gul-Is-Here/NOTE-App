import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/local/db_helper.dart';

class NotesController extends GetxController {
  final DBHelper dbHelper = DBHelper.dbHelper;

  // Reactive list for notes
  var allNotes = <Map<String, dynamic>>[].obs;


  @override
  void onInit() {
    super.onInit();
    getNotes();
  }

  // Fetch all notes from the database
  void getNotes() async {
    allNotes.value = await dbHelper.getAllNotes();
  }

}
