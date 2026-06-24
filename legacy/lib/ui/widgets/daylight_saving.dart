import 'package:alfajr/services/daylight_time_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

showDaylightSavingDialog(BuildContext context, Function updatePrayers) async {
  bool isSwitched = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();

  var confirmMethod = (() {
    if (isSwitched == true) {
      Provider.of<DaylightSavingNotifier>(context, listen: false).setSummerTime();
    } else {
      Provider.of<DaylightSavingNotifier>(context, listen: false).setWinterTime();
    }
    updatePrayers();
    Navigator.pop(context);
  });

  AlertDialog alert = AlertDialog(
      title: const Text("Daylight saving time"),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: confirmMethod,
          child: const Text('Confirm'),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Consumer<DaylightSavingNotifier>(
          builder: (context, daylightSaving, child) => Row(children: [
            const Text("Daylight saving time is: "),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
            ),
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
