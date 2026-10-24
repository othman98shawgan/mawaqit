import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/theme_service.dart';

class MyCard extends StatefulWidget {
  const MyCard({super.key, required this.widget, this.height = 0});

  final double height;
  final Widget widget;

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeNotifier, LocaleNotifier>(
      builder: (context, theme, localeProvider, child) {
        Color bgColor = theme.themeMode == ThemeMode.dark ? prayerBgColorDark : prayerBgColorLight;
        return Directionality(
          textDirection: localeProvider.getTextDirection(localeProvider.locale),
          child: SizedBox(
            height: widget.height > 0 ? widget.height : null,
            child: Card(
              color: bgColor,
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[widget.widget],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
