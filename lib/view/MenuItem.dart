
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({Key key, this.item, this.icon}) : super(key: key);

  final String item;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white.withOpacity(0.4),
      ),
      title: Text(
        item,
        style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: 18),
      ),
    );
  }
}
