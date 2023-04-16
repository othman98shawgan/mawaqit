import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/prayer_methods.dart';

showReminderDialog(BuildContext context, bool reminderStatus, int reminderValue,
    Function updateReminder, Function updateAppBar) async {
  var currentReminderValue = reminderValue;
  var currentReminderStatus = reminderStatus;
  var longPressCount = 0;

  var confirmMethod = (() {
    Navigator.pop(context);
    Provider.of<ReminderNotifier>(context, listen: false).setReminderStatus(currentReminderStatus);
    updateReminder(currentReminderValue);
  });

  var dialogTitle = AppLocalizations.of(context)!.reminderDialogTitle;
  var reminderSetMessage = AppLocalizations.of(context)!.reminderDialogMessage;
  var reminderValueMessage =
      AppLocalizations.of(context)!.reminderPrayerMessage(currentReminderValue.toInt());
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;

  AlertDialog alert = AlertDialog(
      title: Text(dialogTitle),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        ElevatedButton(
          onLongPress: () {
            if (++longPressCount == 5) {
              updateAppBar(true);
              printSnackBar("Developer options available", context);
            }
          },
          onPressed: () => Navigator.pop(context),
          child: Text(cancelString),
        ),
        TextButton(
          onPressed: confirmMethod,
          child: Text(confirmString),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SwitchListTile(
              title: Text(reminderSetMessage),
              value: currentReminderStatus,
              onChanged: (bool value) {
                setState(() {
                  currentReminderStatus = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 20.0),
            child: Row(
              children: [
                Text(
                  reminderValueMessage,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: currentReminderStatus ? null : Colors.grey),
                ),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Slider(
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
