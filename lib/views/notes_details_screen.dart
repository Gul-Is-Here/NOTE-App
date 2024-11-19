import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share/share.dart'; // Import the `share` package
import 'package:sqflight_project/controller/note_controller.dart';
import 'package:sqflight_project/data/local/db_helper.dart';

class NotesDetailsScreen extends StatelessWidget {
  final String nTitle;
  final String nDesc;
  final int nSno;

  NotesDetailsScreen({
    super.key,
    required this.nTitle,
    required this.nDesc,
    required this.nSno,
  });

  final controller = Get.put(NotesController());

  @override
  Widget build(BuildContext context) {
    controller.getNotes();

    // Controllers for title and description
    TextEditingController titleEditingController = TextEditingController();
    TextEditingController descEditingController = TextEditingController();
    titleEditingController.text = nTitle;
    descEditingController.text = nDesc;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            // Save the updated note
            await DBHelper.dbHelper.updateNote(
              mtitle: titleEditingController.text,
              mDesc: descEditingController.text,
              sno: nSno,
            );
            Navigator.of(context).pop(); // Navigate back
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Note Details'),
        actions: [
          IconButton(
            onPressed: () {
              // Share the note using `share` package
              Share.share(
                'Note Title: ${titleEditingController.text}\n\n'
                'Description: ${descEditingController.text}',
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: titleEditingController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 10,
              controller: descEditingController,
              decoration: const InputDecoration(
                hintText: 'Enter description',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Share the note using `share` package
          Share.share(
            'Note Title: ${titleEditingController.text}\n\n'
            'Description: ${descEditingController.text}',
          );
        },
        label: const Text('Share Note'),
        icon: const Icon(Icons.share),
      ),
    );
  }
}
