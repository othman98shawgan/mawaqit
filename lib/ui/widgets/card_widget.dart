import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/theme_service.dart';

class MyCard extends StatefulWidget {
  const MyCard({Key? key, required this.widget}) : super(key: key);

  final Widget widget;

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeNotifier>(context, listen: false).getThemeStr();
    Color bgColor;
    if (theme == 'dark') {
      bgColor = const Color.fromARGB(180, 0, 0, 0);
    } else {
      bgColor = const Color.fromARGB(180, 255, 255, 255);
    }
    return Consumer<ThemeNotifier>(
        builder: (context, theme, child) => Card(
              color: bgColor,
              child: Column(
                children: <Widget>[widget.widget],
              ),
            ));
  }
}
