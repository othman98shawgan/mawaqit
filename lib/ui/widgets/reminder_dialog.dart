import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../../resources/colors.dart';

Future<void> showReminderDialog(BuildContext context, bool reminderStatus, int reminderValue, Function updateReminder) async {
  var currentReminderValue = reminderValue;
  var currentReminderStatus = reminderStatus;

  var confirmMethod = (() {
    Navigator.pop(context);
    Provider.of<ReminderNotifier>(context, listen: false).setReminderStatus(currentReminderStatus);
    updateReminder(currentReminderValue);
  });

  var dialogTitle = AppLocalizations.of(context)!.reminderDialogTitle;
  var reminderSetMessage = AppLocalizations.of(context)!.reminderDialogMessage;
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;
  var isLight = Theme.of(context).brightness == Brightness.light;
  var textColor = isLight ? Colors.black : Colors.white;

  AlertDialog alert = AlertDialog(
      title: Text(dialogTitle, style: TextStyle(color: textColor)),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelString),
        ),
        ElevatedButton(
          onPressed: confirmMethod,
          child: Text(confirmString),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SwitchListTile(
              title: Text(reminderSetMessage, style: TextStyle(color: textColor)),
              value: currentReminderStatus,
              activeThumbColor: Colors.white,
              activeTrackColor: isLight ? color3 : darkThemeSwatch,
              inactiveThumbColor: isLight ? const Color(0xFF72796F) : Colors.grey.shade400,
              inactiveTrackColor: isLight ? const Color(0xFFE0E3DC) : Colors.grey.shade800,
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.transparent;
                }
                return isLight ? const Color(0xFF72796F) : Colors.grey.shade500;
              }),
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Icon(Icons.check, color: isLight ? color3 : darkThemeSwatch);
                }
                return Icon(Icons.close, color: isLight ? const Color(0xFFE0E3DC) : Colors.grey.shade800);
              }),
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
                  AppLocalizations.of(context)!.reminderPrayerMessage(currentReminderValue.toInt()),
                  textAlign: TextAlign.start,
                  style: TextStyle(color: currentReminderStatus ? textColor : Colors.grey),
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
