import 'package:flutter/material.dart';

showReminderDialog(BuildContext context, int reminderValue, Function updateReminder) async {
  var currentReminderValue = reminderValue;

  var confirmMethod = (() {
    Navigator.pop(context);
    updateReminder(currentReminderValue);
  });

  AlertDialog alert = AlertDialog(
      title: const Text("Prayer reminder"),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: confirmMethod,
          child: const Text('Confirm'),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
            child: Row(
              children: [
                Text(
                  "Reminder for each prayer: ${currentReminderValue.toInt()}",
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Slider(
              value: currentReminderValue.toDouble(),
              max: 30,
              divisions: 30,
              label: currentReminderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  currentReminderValue = value.toInt();
                });
              }),
        ]);
      }));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
