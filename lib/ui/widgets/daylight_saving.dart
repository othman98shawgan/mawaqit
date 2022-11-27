import 'package:alfajr/services/daylight_time_service.dart';
import 'package:flutter/material.dart';

showAlertDialog(BuildContext context) async {
  bool isSwitched = await getSummerTime();
  var confirmMethod = (() {
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
        return Row(children: [
          const Text("Daylight saving time is: "),
          Switch(
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
                setSummerTime(value);
              });
            },
          ),
        ]);
      }));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
