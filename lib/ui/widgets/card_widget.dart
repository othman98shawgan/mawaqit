import 'package:flutter/material.dart';

class MyCard extends StatefulWidget {
  const MyCard({Key? key, required this.widget}) : super(key: key);

  final Widget widget;

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(180, 0, 0, 0),
      // color: Colors.black54,
      child: Column(
        children: <Widget>[widget.widget],
      ),
    );
  }
}
