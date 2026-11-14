import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showDaylightSavingDialog(BuildContext context, Function updatePrayers) async {
  bool isSwitched = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();
  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final localeProvider = Provider.of<LocaleNotifier>(context, listen: false);
  final textDirection = localeProvider.getTextDirection(localeProvider.locale);
  final textColor = isDark ? Colors.white : Colors.black87;

  await showModalBottomSheet<void>(
    context: context,
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
                      l10n.daylightSavingDialogTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.daylightSavingStatus, style: TextStyle(color: textColor)),
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
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
                            if (isSwitched) {
                              Provider.of<DaylightSavingNotifier>(context, listen: false).setSummerTime();
                            } else {
                              Provider.of<DaylightSavingNotifier>(context, listen: false).setWinterTime();
                            }
                            updatePrayers();
                            Navigator.pop(sheetContext);
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
