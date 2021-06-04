import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    title: "Daily To Do",
    debugShowCheckedModeBanner: false,
    home: HomePage(
      title: "My daily to do",
    ),
    theme: ThemeData(primarySwatch: Colors.blue),
  ));
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _todo_list = [];
  TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _lastRemoved;
  int _lastIndex;

  add_todo() {
    setState(() {
      var todo = Map();
      todo["name"] = _controller.text;
      todo["status"] = false;
      todo["time"] =
          "${DateTime.now().day.toString().padLeft(2, '0')} - ${DateTime.now().month.toString().padLeft(2, '0')} - ${DateTime.now().year.toString()}";
      _todo_list.add(todo);
      _controller.text = "";
      _saveData();
    });
  }

  @override
  void initState() {
    super.initState();
    _readFile().then((data) {
      setState(() {
        _todo_list = json.decode(data);
      });
    });
  }

  Future<Null> _getTodo() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _todo_list.sort((a, b) {
        if (a["status"] && !b["status"])
          return 1;
        else if (!a["status"] && b["status"])
          return -1;
        else
          return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(
                Icons.sort_by_alpha_rounded,
                size: 25,
              ),
              onPressed: () {
                setState(() {});
              })
        ],
      ),
      body: _todo_list.length != 0
          ? Container(
              child: RefreshIndicator(
              onRefresh: _getTodo,
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: _todo_list.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                        key: Key(
                            DateTime.now().microsecondsSinceEpoch.toString()),
                        background: Container(
                          color: Colors.red,
                          child: Align(
                            alignment: Alignment(-0.9, 0.0),
                            child:
                                Icon(Icons.delete_forever, color: Colors.white),
                          ),
                        ),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          setState(() {
                            _lastRemoved = Map.from(_todo_list[index]);
                            _lastIndex = index;
                            _todo_list.removeAt(index);
                            _saveData();

                            final snackBar = SnackBar(
                              content: Text(
                                  "The task ${_lastRemoved["name"]} was deleted!"),
                              action: SnackBarAction(
                                label: "Undo",
                                onPressed: () {
                                  setState(() {
                                    _todo_list.insert(_lastIndex, _lastRemoved);
                                    _saveData();
                                  });
                                },
                              ),
                              duration: Duration(seconds: 2),
                            );

                            ScaffoldMessenger.maybeOf(context)
                                .showSnackBar(snackBar);
                          });
                        },
                        child: CheckboxListTile(
                            title: Text(_todo_list[index]["name"]),
                            subtitle: Text(
                                "Created at: ${_todo_list[index]["time"]}"),
                            secondary: CircleAvatar(
                                child: Icon(
                              _todo_list[index]["status"]
                                  ? Icons.check
                                  : Icons.error,
                              size: 40,
                            )),
                            value: _todo_list[index]["status"],
                            onChanged: (value) {
                              setState(() {
                                _todo_list[index]["status"] = value;
                                _saveData();
                              });
                            }));
                  }),
            ))
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/empty.png",
                  height: 200,
                  width: 200,
                ),
                Text(
                  "Your list is empty",
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                )
              ],
            )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        tooltip: "Add new To do",
        autofocus: true,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                        child: Text(
                      "Add new to do",
                      style: TextStyle(color: Colors.blue),
                    )),
                    content: Container(
                      height: 50,
                      child: Column(
                        children: [
                          TextField(
                            controller: _controller,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: "Type the activity's name"),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.green),
                          ),
                          onPressed: () {
                            add_todo();
                          },
                          child: Text("Add now")),
                    ],
                  );
                });
          });
        },
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String content = json.encode(_todo_list);
    final file = await _getFile();

    return file.writeAsString(content);
  }

  Future<String> _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
