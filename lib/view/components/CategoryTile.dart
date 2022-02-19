import 'package:flutter/material.dart';
import 'package:my_daily_to_do/model/Category.dart';

class CategoryTile extends StatelessWidget {
  CategoryTile({Key key, this.category}) : super(key: key);
  Category category;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        //elevation: ,
        borderOnForeground: false,
        shadowColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Container(
            padding: EdgeInsets.all(12),
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("${category.tasks} tasks", style: TextStyle(color: Colors.black38)),
                Text(
                  "${category.name}",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                      fontSize: 24),
                )
              ],
            )),
      ),
    );
  }
}
