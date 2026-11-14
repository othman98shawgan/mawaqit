import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alfajr/l10n/app_localizations.dart';

Future<void> showReminderDialog(BuildContext context, bool reminderStatus, int reminderValue, Function updateReminder) async {
  var currentReminderValue = reminderValue;
  var currentReminderStatus = reminderStatus;

  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black87;
  final localeProvider = Provider.of<LocaleNotifier>(context, listen: false);
  final textDirection = localeProvider.getTextDirection(localeProvider.locale);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: isDark ? appBarColor : color1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return Directionality(
        textDirection: textDirection,
        child: SafeArea(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.reminderDialogTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.reminderDialogMessage, style: TextStyle(color: textColor)),
                      value: currentReminderStatus,
                      onChanged: (bool value) {
                        setState(() {
                          currentReminderStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.reminderPrayerMessage(currentReminderValue.toInt()),
                      textAlign: TextAlign.start,
                      style: TextStyle(color: currentReminderStatus ? textColor : Colors.grey),
                    ),
                    const SizedBox(height: 4),
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
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(l10n.cancelString),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            Provider.of<ReminderNotifier>(context, listen: false).setReminderStatus(currentReminderStatus);
                            updateReminder(currentReminderValue);
                          },
                          child: Text(l10n.confirmString),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
