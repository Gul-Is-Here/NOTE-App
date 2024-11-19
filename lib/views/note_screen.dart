import 'package:flutter/material.dart';
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
    allnotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
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
        title: const Text(
          'Notes',
          style: TextStyle(color: Colors.white),
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
                    key: ValueKey(
                      allnotes[index][DBHelper.column_note_sr_no],
                    ),
                    background: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Note'),
                          content: const Text(
                              'Are you sure you want to delete this note? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(false); // Cancel deletion
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(true); // Confirm deletion
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      final deletedNote = allnotes[index];
                      await dbRef!.deleteNote(
                        sno: deletedNote[DBHelper.column_note_sr_no],
                      );

                      setState(() {
                        allnotes.removeAt(index);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Note deleted successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          allnotes[index][DBHelper.column_note_sr_no]
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        allnotes[index][DBHelper.column_note_title],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        allnotes[index][DBHelper.column_note_desc],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Title',
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
              labelText: 'Description',
              hintText: 'Enter a description...',
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
                    titleController.clear();
                    desController.clear();
                    getNotes();
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Add Note',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Cancel',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
