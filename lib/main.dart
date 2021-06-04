import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_daily_to_do/control.dart';
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
  List _todoList = [];
  TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _lastRemoved;
  int _lastIndex;

  // Method to add new todo to our file.

  addNewTodo() {
    setState(() {
      var todo = Map();
      todo["name"] = _controller.text;
      todo["status"] = false;
      todo["time"] =
          "${DateTime.now().day.toString().padLeft(2, '0')} - ${DateTime.now().month.toString().padLeft(2, '0')} - ${DateTime.now().year.toString()}";
      _todoList.add(todo);
      _controller.text = "";
      Control.saveData(_todoList);
    });
  }

  // get organized todos
  Future<Null> _getOrganizedTodo() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _todoList.sort((a, b) {
        if (a["status"] && !b["status"])
          return 1;
        else if (!a["status"] && b["status"])
          return -1;
        else
          return 0;
      });
      Control.saveData(_todoList);
    });
  }

  Container _buildTodoFoundWidget() {
    return Container(
        child: RefreshIndicator(
      onRefresh: _getOrganizedTodo,
      child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: _todoList.length,
          itemBuilder: (context, index) {
            return Dismissible(
                key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
                background: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment(-0.9, 0.0),
                    child: Icon(Icons.delete_forever, color: Colors.white),
                  ),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  setState(() {
                    _lastRemoved = Map.from(_todoList[index]);
                    _lastIndex = index;
                    _todoList.removeAt(index);
                    Control.saveData(_todoList);

                    final snackBar = SnackBar(
                      content:
                          Text("The task ${_lastRemoved["name"]} was deleted!"),
                      action: SnackBarAction(
                        label: "Undo",
                        onPressed: () {
                          setState(() {
                            _todoList.insert(_lastIndex, _lastRemoved);
                            Control.saveData(_todoList);
                          });
                        },
                      ),
                      duration: Duration(seconds: 2),
                    );

                    ScaffoldMessenger.maybeOf(context).showSnackBar(snackBar);
                  });
                },
                child: CheckboxListTile(
                    title: Text(_todoList[index]["name"]),
                    subtitle: Text("Created at: ${_todoList[index]["time"]}"),
                    secondary: CircleAvatar(
                        child: Icon(
                      _todoList[index]["status"] ? Icons.check : Icons.error,
                      size: 40,
                    )),
                    value: _todoList[index]["status"],
                    onChanged: (value) {
                      setState(() {
                        _todoList[index]["status"] = value;
                        Control.saveData(_todoList);
                      });
                    }));
          }),
    ));
  }

  Center _buildNoTodoFoundWidget() {
    return Center(
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
    ));
  }

  @override
  void initState() {
    super.initState();
    Control.readFile().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      //if list is not empty show the todos, otherwise show noTodoFound
      body: _todoList.length != 0
          ? _buildTodoFoundWidget()
          : _buildNoTodoFoundWidget(),

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
                            addNewTodo();
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
}
