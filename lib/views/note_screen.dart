import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflight_project/utility/fonts.dart';
import 'package:sqflight_project/views/notes_details_screen.dart';

import '../data/local/db_helper.dart';
import '../utility/colors.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var titleController = TextEditingController();
  var desController = TextEditingController();
  var allnotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.dbHelper;
    getNotes();
  }

  void getNotes() async {
    var notes = await dbRef!.getAllNotes();
    allnotes = List.from(notes); // Ensure `allnotes` is mutable
    setState(() {});
  }

  void showIOSActionSheet({
    required BuildContext context,
    required int index,
    required Map<String, dynamic> deletedNote,
  }) {
    showAdaptiveDialog(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          'Delete Note',
          style: TextStyle(
              fontFamily: cormo, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        message: Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
          style: TextStyle(fontFamily: cormo, fontSize: 16),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);

              // Temporarily remove the note
              setState(() {
                allnotes.removeAt(index);
              });

              // Show SnackBar with Undo option
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Note deleted',
                    style: TextStyle(
                        fontFamily: cormo,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  action: SnackBarAction(
                    backgroundColor: primaryColor,
                    label: 'Undo',
                    onPressed: () {
                      setState(() {
                        allnotes.insert(index, deletedNote);
                      });
                    },
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );

              // Wait 5 seconds to confirm deletion if not undone
              await Future.delayed(const Duration(seconds: 5));
              if (!allnotes.contains(deletedNote)) {
                await dbRef!.deleteNote(
                  sno: deletedNote[DBHelper.column_note_sr_no],
                );
              }
            },
            isDestructiveAction: true,
            child: const Text(
              'Delete',
              style: TextStyle(
                  fontFamily: cormo, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx); // Close the action sheet
              setState(() {
                // Restore the note if canceled
                allnotes.insert(index, deletedNote);
              });
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                  fontFamily: cormo, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getNotes();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true, // Allows full-screen height adjustment
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return showModelBottomSheet();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Notes',
          style: TextStyle(
              color: Colors.white,
              fontFamily: cormo,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: allnotes.isNotEmpty
          ? ListView.builder(
              itemCount: allnotes.length,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemBuilder: (_, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Dismissible(
                    key: ValueKey(allnotes[index][DBHelper.column_note_sr_no]),
                    background: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    onDismissed: (_) {
                      final deletedNote = allnotes[index];
                      setState(() {
                        allnotes
                            .removeAt(index); // Safe as the list is now mutable
                      });
                      showIOSActionSheet(
                        context: context,
                        index: index,
                        deletedNote: deletedNote,
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: sanSarif,
                            color: secondaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        allnotes[index][DBHelper.column_note_title],
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: sanSarif,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        allnotes[index][DBHelper.column_note_desc],
                        style: TextStyle(
                          fontFamily: sanSarif,
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey[500],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NotesDetailsScreen(
                            nTitle: allnotes[index][DBHelper.column_note_title],
                            nDesc: allnotes[index][DBHelper.column_note_desc],
                            nSno: allnotes[index][DBHelper.column_note_sr_no],
                          ),
                        ));
                      },
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text('No Note added yet'),
            ),
    );
  }

  Widget showModelBottomSheet() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              20, // Adjust for keyboard
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Note',
              style: TextStyle(
                fontSize: 20,
                fontFamily: cormo,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontFamily: cormo, fontWeight: FontWeight.bold),
                labelText: 'Title',
                hintStyle:
                    TextStyle(fontFamily: cormo, fontWeight: FontWeight.bold),
                hintText: 'Enter a title (e.g., Grocery)',
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: desController,
              maxLines: 4,
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontFamily: cormo, fontWeight: FontWeight.bold),
                labelText: 'Description',
                hintText: 'Enter a description...',
                hintStyle:
                    TextStyle(fontFamily: cormo, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await dbRef!.addNote(
                        noteTitle: titleController.text,
                        noteDesc: desController.text,
                      );
                      getNotes();
                      Navigator.pop(context); // Close modal after adding
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Add Note',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: cormo,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close modal on cancel
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: cormo,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
