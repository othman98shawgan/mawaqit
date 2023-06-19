import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/services/locale_service.dart';
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
    Color bgColor = theme == 'dark' ? prayerBgColorDark : prayerBgColorLight;

    return Consumer2<ThemeNotifier, LocaleNotifier>(
      builder: (context, theme, localeProvider, child) => Directionality(
        textDirection: localeProvider.getTextDirection(localeProvider.locale),
        child: SizedBox(
          height: widget.height > 0 ? widget.height : null,
          child: Card(
            color: bgColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[widget.widget],
            ),
          ),
        ),
      ),
    );
  }
}
