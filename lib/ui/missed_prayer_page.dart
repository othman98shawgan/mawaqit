import 'package:alfajr/models/prayer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/card_widget.dart';

class MissedPrayerPage extends StatefulWidget {
  const MissedPrayerPage({Key? key}) : super(key: key);

  @override
  State<MissedPrayerPage> createState() => _MissedPrayerPageState();
}

class _MissedPrayerPageState extends State<MissedPrayerPage> {
  var prayers = List.filled(6, 0, growable: false);
  var missedPrayersStringList = [
    'missedFajr',
    'missedDuhr',
    'missedAsr',
    'missedMaghrib',
    'missedIsha',
    'missedWitr'
  ];

  Future<List<int>> getAllMissed() async {
    final prefs = await SharedPreferences.getInstance();
    final fajr = prefs.getInt('missedFajr') ?? 0;
    final duhr = prefs.getInt('missedDuhr') ?? 0;
    final asr = prefs.getInt('missedAsr') ?? 0;
    final maghrib = prefs.getInt('missedMaghrib') ?? 0;
    final isha = prefs.getInt('missedIsha') ?? 0;
    final witr = prefs.getInt('missedWitr') ?? 0;
    prayers = [fajr, duhr, asr, maghrib, isha, witr];
    return prayers;
  }

  Future<void> setMissedPrayer(int prayerIndex, int missedSum) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(missedPrayersStringList[prayerIndex], missedSum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _fab(0),
      appBar: AppBar(
        title: const Text('Missed Prayers'),
      ),
      body: FutureBuilder(
        future: getAllMissed(),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                children: [
                  _missedPrayerWidget("Fajr", 0),
                  _missedPrayerWidget("Duhr", 1),
                  _missedPrayerWidget("Asr", 2),
                  _missedPrayerWidget("Maghrib", 3),
                  _missedPrayerWidget("Isha", 4),
                  // _missedPrayerWidget("Witr", 5),
                ],
              ),
            );
          } else {
            // Return loading screen while reading preferences
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _missedPrayerWidget(String label, int index) {
    var style = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 24,
    );
    // Full screen width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;
    double height1 = height - padding.top - padding.bottom;

    // Height (without status bar)
    double height2 = height - padding.top;

    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;

    return MyCard(
        widget: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Container(
            width: width * 0.35,
            height: height3 * 0.1,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
        Container(
          width: width * 0.2,
          alignment: Alignment.center,
          child: Text(
            '${prayers[index]}',
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            width: width * 0.4,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [_incrementButton(index), _doneButton(index)]))
      ],
    ));
  }

  Widget _fab(int index) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () {
        setState(() {
          for (int i = 0; i < prayers.length; i++) {
            prayers[i]++;
            setMissedPrayer(i, prayers[i]);
          }
        });
      },
      child: const Icon(Icons.add, color: Colors.black87),
    );
  }

  Widget _incrementButton(int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          prayers[index]++;
          setMissedPrayer(index, prayers[index]);
        });
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
        primary: Colors.grey,
      ),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _doneButton(int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (prayers[index] > 0) {
            prayers[index]--;
            setMissedPrayer(index, prayers[index]);
          }
        });
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
        primary: Colors.green,
      ),
      child: const Icon(Icons.done, color: Colors.white),
    );
  }
}
