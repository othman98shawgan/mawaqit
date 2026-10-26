import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/services/daylight_time_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showDaylightSavingDialog(BuildContext context, Function updatePrayers) async {
  bool isSwitched = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();
  final l10n = AppLocalizations.of(context)!;

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
      title: Text(l10n.daylightSavingDialogTitle),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelString)),
        TextButton(
          onPressed: confirmMethod,
          child: Text(l10n.confirmString),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Consumer<DaylightSavingNotifier>(
          builder: (context, daylightSaving, child) => Row(children: [
            Text(l10n.daylightSavingStatus),
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
