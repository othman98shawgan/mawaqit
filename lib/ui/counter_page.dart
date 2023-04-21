import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/dhikr_service.dart';
import '../services/store_manager.dart';
import '../services/theme_service.dart';
import 'settings_dhikr_page.dart';
import 'settings_page.dart';
import 'dart:ui' as ui;

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late int _counter;
  final double _bigFontSize = 112;
  final double _smallFontSize = 96;
  late double _currnetFontSize;

  void _incrementCounter(DhikrNotifier dhikr) {
    setState(() {
      _counter++;
    });
    StorageManager.saveData('Counter', _counter);
    if (_counter >= 10000) {
      setState(() {
        _currnetFontSize = _smallFontSize;
      });
    }
    if (_counter % dhikr.getDhikrTarget() != 0) {
      //vibrate on tap
      if (dhikr.getVibrateOnTap()) {
        Vibrate.feedback(FeedbackType.medium);
      }
    } else {
      //vibrate on target reach
      if (dhikr.getVibrateOnCountTarget()) {
        Vibrate.feedback(FeedbackType.warning);
      }
    }
  }

  void _resetCounter() async {
    Vibrate.feedback(FeedbackType.error);
    setState(() {
      _counter = 0;
      _currnetFontSize = _bigFontSize;
      StorageManager.saveData('Counter', _counter);
    });
  }

  Future<void> getSharedPrefs() async {
    StorageManager.readData('Counter').then((value) {
      setState(() {
        _counter = value ?? 0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = 0;
    _currnetFontSize = _bigFontSize;
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    var titleString = AppLocalizations.of(context)!.dhikrString;
    var settingsTooltip = AppLocalizations.of(context)!.settingsString;
    var resetTooltip = AppLocalizations.of(context)!.resetCountTooltip;

    return Consumer2<DhikrNotifier, ThemeNotifier>(
      builder: (context, dhikr, theme, _) => Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text(titleString),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: resetTooltip,
                onPressed: _resetCounter,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: settingsTooltip,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsDhikrPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: _resetCounter,
            onTap: (() {
              _incrementCounter(dhikr);
            }),
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width * 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    color: theme.getTheme() == theme.darkTheme
                        ? Colors.black54
                        : const Color.fromARGB(120, 96, 125, 139),
                  ),
                  child: Center(
                    child: Text(_counter.toString().padLeft(4, '0'),
                        style: Theme.of(context).textTheme.headline1?.merge(
                            TextStyle(fontSize: _currnetFontSize, fontWeight: FontWeight.w100))),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
