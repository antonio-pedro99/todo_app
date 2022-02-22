import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_daily_to_do/model/Category.dart';

import '../../control.dart';
import '../components/CategoryTile.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _todoList = [];
  TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _lastRemoved;
  int _lastIndex;
  List<Category> categories = [
    Category(name: "Business", tasks: 0),
    Category(name: "College", tasks: 0)
  ];

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
              child: Card(
                //elevation: ,
                borderOnForeground: false,
                shadowColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      _todoList[index]["name"],
                      style: TextStyle(),
                    ),
                    subtitle: Text("Created on: ${_todoList[index]["time"]}"),
                    /*  secondary: CircleAvatar(
                        child: Icon(
                      _todoList[index]["status"] ? Icons.check : Icons.error,
                      size: 40,
                    )), */
                    value: _todoList[index]["status"],
                    onChanged: (value) {
                      setState(() {
                        _todoList[index]["status"] = value;
                        Control.saveData(_todoList);
                      });
                    }),
              ),
            );
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
    var size = MediaQuery.of(context).size;

    return Scaffold(
//if list is not empty show the todos, otherwise show noTodoFound
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            stretch: true,
            elevation: 0,
            backgroundColor: Colors.white,
            /*  leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.grey,
                size: 25,
              ),
              onPressed: () {},
            ), */
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 30,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey,
                    size: 30,
                  ))
            ],
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SafeArea(
                child: Container(
              padding: EdgeInsets.all(15),
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Hey, sup?",
                    style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 35,
                        color: Colors.black54),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Categories",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.black54),
                  ),
                  //build category list
                  SizedBox(height: 15),
                  Container(
                      height: 110,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: categories.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return CategoryTile(category: categories[index]);
                          })),
                  SizedBox(height: 20),
                  Text(
                    "Today's tasks",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.black54),
                  ),
                  //build category list
                  SizedBox(height: 15),
                  Expanded(
                      child: Container(
                    child: _todoList.length != 0
                        ? _buildTodoFoundWidget()
                        : _buildNoTodoFoundWidget(),
                  ))
                ],
              ),
            ))
          ]))
        ],
      ),

      /* _todoList.length != 0
          ? _buildTodoFoundWidget()
          : _buildNoTodoFoundWidget(), */

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
            print("Hello world");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  Category selectedCategory = categories[0];
                  return AlertDialog(
                    title: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300)),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey,
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    content: Container(
                      height: 130,
                      child: Column(
                        children: [
                          TextField(
                            controller: _controller,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w300),
                                hintText: "Type the activity's name"),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Category: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 20,
                                width: 10,
                              ),
                              Container(
                                height: 10,
                                alignment: Alignment.topCenter,
                                child: DropdownButton<Category>(
                                    elevation: 3,
                                    //isExpanded: true,
                                    alignment: Alignment.topCenter,
                                    value: selectedCategory,
                                    items: categories
                                        .map<DropdownMenuItem<Category>>((e) {
                                      return DropdownMenuItem<Category>(
                                          alignment: Alignment.center,
                                          value: e,
                                          child: Text(e.name));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value;
                                      });
                                    }),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    actions: [
                      Center(
                          child: ElevatedButton(
                              style: TextButton.styleFrom(
                                fixedSize: Size(100, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                backgroundColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue),
                              ),
                              onPressed: () {
                                if (_controller.text.length > 0 &&
                                    _controller.text != "") {
                                  addNewTodo();
                                  Navigator.pop(context);
                                }
                              },
                              child: Center(
                                child: Text("New task",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal)),
                              ))),
                    ],
                  );
                });
          });
        },
      ),
    );
  }
}
