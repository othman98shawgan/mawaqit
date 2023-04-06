import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

showReminderDialog(
    BuildContext context, bool reminderStatus, int reminderValue, Function updateReminder) async {
  var currentReminderValue = reminderValue;
  var currentReminderStatus = reminderStatus;

  var confirmMethod = (() {
    Navigator.pop(context);
    Provider.of<ReminderNotifier>(context, listen: false).setReminderStatus(currentReminderStatus);
    updateReminder(currentReminderValue);
  });

  AlertDialog alert = AlertDialog(
      title: const Text("Prayer reminder"),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: confirmMethod,
          child: const Text('Confirm'),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SwitchListTile(
              title: const Text('Set prayer reminder'),
              value: currentReminderStatus,
              onChanged: (bool value) {
                setState(() {
                  currentReminderStatus = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 24.0, 20.0),
            child: Row(
              children: [
                Text(
                  "Reminder for each prayer: ${currentReminderValue.toInt()}",
                  textAlign: TextAlign.start,
                  style: TextStyle(color: currentReminderStatus ? null : Colors.grey),
                ),
              ],
            ),
          ),
          Slider(
              value: currentReminderValue.toDouble(),
              max: 30,
              divisions: 30,
              label: currentReminderValue.round().toString(),
              onChanged: currentReminderStatus
                  ? (double value) {
                      setState(() {
                        currentReminderValue = value.toInt();
                      });
                    }
                  : null),
        ]);
      }));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
