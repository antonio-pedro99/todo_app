import 'package:flutter/material.dart';
import 'package:my_daily_to_do/view/components/MenuItem.dart';
import 'package:my_daily_to_do/view/pages/home.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(join(await getDatabasesPath(), "todos.db"));

  
  runApp(MaterialApp(
    title: "Daily To Do",
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Urbanist',
        primarySwatch: Colors.blue),
  ));
}

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    return DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
        ),
        child: Container(
            width: media.size.width,
            color: Color.fromRGBO(2, 4, 23, 1),
            child: Padding(
                padding: EdgeInsets.only(left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    MenuItem(item: "Templates", icon: Icons.bookmark_outline),
                    SizedBox(height: 5),
                    MenuItem(item: "Category", icon: Icons.category_outlined),
                    SizedBox(height: 5),
                    MenuItem(item: "Analytics", icon: Icons.analytics_outlined),
                    SizedBox(height: 5),
                    MenuItem(item: "Settings", icon: Icons.settings_outlined),
                  ],
                ))));
  }
}
