import 'package:flutter/material.dart';
import 'package:sqflight_project/data/local/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var allnotes = [];
  DBHelper? dbRef;
  @override
  void initState() {
    // TODO: implement initState
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
              // context and builder are
              // required properties in this widget
              context: context,
              builder: (BuildContext context) {
                // we set up a container inside which
                // we create center column and display text

                // Returning SizedBox instead of a Container
                return Container(
                  // height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              label: const Text('Title'),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLines: 5,
                          decoration: InputDecoration(
                              label: const Text('Description'),
                              hintText: 'Enter Description',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  onPressed: () {}, child: Text('Add Notes')),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                onPressed: () {}, child: Text('Cancel')),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(
            'Notes',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  // showModalBottomSheet(context: context, builder: ())
                  print('pressed');
                  // bool check = await dbRef!.addNote(
                  //     noteTitle: 'Money Managment',
                  //     noteDesc: ' This Is a dummy Notes');
                  // if (check) {
                  //   print('Notes Get');
                  //   getNotes();
                  // }
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ))
          ],
        ),
        body: allnotes.isNotEmpty
            ? ListView.builder(
                itemCount: allnotes.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    leading: Text(
                        allnotes[index][DBHelper.column_note_sr_no].toString()),
                    title: Text(allnotes[index][DBHelper.column_note_title]),
                    subtitle: Text(allnotes[index][DBHelper.column_note_desc]),
                  );
                },
              )
            : Center(
                child: Text('No Note added yet'),
              ));
  }
}
