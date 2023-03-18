import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/theme_service.dart';

class MyCard extends StatefulWidget {
  const MyCard({Key? key, required this.widget, this.height = 0}) : super(key: key);

  final double height;
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
      builder: (context, theme, child) => SizedBox(
        height: widget.height > 0 ? widget.height : null,
        child: Card(
          color: bgColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[widget.widget],
          ),
        ),
      ),
    );
  }
}
