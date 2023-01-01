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
  ];

  Future<List<int>> getAllMissed() async {
    final prefs = await SharedPreferences.getInstance();

    final fajr = prefs.getInt(missedPrayersStringList[0]) ?? 0;
    final duhr = prefs.getInt(missedPrayersStringList[1]) ?? 0;
    final asr = prefs.getInt(missedPrayersStringList[2]) ?? 0;
    final maghrib = prefs.getInt(missedPrayersStringList[3]) ?? 0;
    final isha = prefs.getInt(missedPrayersStringList[4]) ?? 0;
    prayers = [fajr, duhr, asr, maghrib, isha];
    return prayers;
  }

  Future<void> clearAllMissed() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < missedPrayersStringList.length; i++) {
      prefs.setInt(missedPrayersStringList[i], 0);
    }
  }

  Future<void> setMissedPrayer(int prayerIndex, int missedSum) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(missedPrayersStringList[prayerIndex], missedSum);
  }

  @override
  Widget build(BuildContext context) {
    // Full screen width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;

    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;

    return Scaffold(
      floatingActionButton: _fab(0),
      appBar: AppBar(
        title: const Text('Missed Prayers'),
      ),
      body: FutureBuilder(
        future: getAllMissed(),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                _missedPrayerWidget("Fajr", 0),
                _missedPrayerWidget("Duhr", 1),
                _missedPrayerWidget("Asr", 2),
                _missedPrayerWidget("Maghrib", 3),
                _missedPrayerWidget("Isha", 4),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02, top: height3 * 0.01),
                      child: ElevatedButton(
                        onPressed: () async {
                          showClearAllDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          primary: Colors.red,
                        ),
                        child: const Text(
                          "Clear all",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
        showAddMissedPrayersDialog(context);
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

  Widget _addDaysButton(int amount, String label) {
    double width = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          for (int i = 0; i < prayers.length; i++) {
            prayers[i] += amount;
            setMissedPrayer(i, prayers[i]);
          }
        });
      },
      style: ElevatedButton.styleFrom(
          fixedSize: Size(width * 0.4, 0), padding: const EdgeInsets.all(10)),
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  showAddMissedPrayersDialog(BuildContext context) async {
    double height = MediaQuery.of(context).size.height;

    AlertDialog alert = AlertDialog(
        title: const Text("Add missed prayers"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            height: height * 0.2,
            child: Column(children: [
              _addDaysButton(7, "Add Week"),
              _addDaysButton(30, "Add Month"),
              _addDaysButton(365, "Add Year"),
            ]),
          );
        }));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showClearAllDialog(BuildContext context) async {
    var confirmMethod = (() {
      setState(() {
        clearAllMissed();
      });
      Navigator.pop(context);
    });

    AlertDialog alert = AlertDialog(
        title: const Text("Clear All"),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: confirmMethod,
            child: const Text('Confirm'),
          ),
        ],
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return const Text("Are you sure you want to clear all missed prayers?");
        }));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
