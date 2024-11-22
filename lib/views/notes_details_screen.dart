import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart'; // Updated to use `share_plus`
import 'package:sqflight_project/controller/note_controller.dart';
import 'package:sqflight_project/data/local/db_helper.dart';
import 'package:sqflight_project/utility/colors.dart';

import '../utility/fonts.dart';

class NotesDetailsScreen extends StatelessWidget {
  final String nTitle;
  final String nDesc;
  final int nSno;

  NotesDetailsScreen({
    Key? key,
    required this.nTitle,
    required this.nDesc,
    required this.nSno,
  }) : super(key: key);

  final controller = Get.put(NotesController());

  @override
  Widget build(BuildContext context) {
    controller.getNotes();

    TextEditingController titleEditingController = TextEditingController();
    TextEditingController descEditingController = TextEditingController();
    titleEditingController.text = nTitle;
    descEditingController.text = nDesc;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          onPressed: () async {
            await DBHelper.dbHelper
                .updateNote(
              mtitle: titleEditingController.text,
              mDesc: descEditingController.text,
              sno: nSno,
            )
                .then((v) {
              SnackBar(
                  content: Card(
                child: Text('Save Successfully'),
              ));
            });
            Navigator.of(context).pop(); // Navigate back
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Note Details',
          style: TextStyle(
              fontFamily: cormo,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontFamily: sanSarif,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextFormField(
                      controller: titleEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Enter title',
                        border: UnderlineInputBorder(),
                      ),
                      style: const TextStyle(
                        fontFamily: sanSarif,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontFamily: sanSarif,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextFormField(
                      controller: descEditingController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: 'Enter description',
                        border: UnderlineInputBorder(),
                      ),
                      style: const TextStyle(
                        fontFamily: sanSarif,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () {
          Share.share(
            'Note Title: ${titleEditingController.text}\n\n'
            'Description: ${descEditingController.text}',
          );
        },
        label: const Text(
          'Share Note',
          style: TextStyle(
              fontFamily: sanSarif,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        icon: const Icon(
          Icons.share,
          color: Colors.white,
        ),
      ),
    );
  }
}
